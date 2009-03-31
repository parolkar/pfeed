#snippet: https://gist.github.com/89e92409ca9016d2d919

module ParolkarInnovationLab
  module SocialNet
    def self.included(base)
      base.extend ParolkarInnovationLab::SocialNet::ClassMethods
    end
    
    module ClassMethods
      def emits_pfeeds items_array
        include ParolkarInnovationLab::SocialNet::InstanceMethods
        profile_item_types_for_this_model = Array.new
              
        #Check validity of these item names as per master configuration list
        items_array.each { |item|
          if PROFILE_ITEM_TYPE.include?(item)
           profile_item_types_for_this_model.push item
          else
            raise "has_profile_items [...:#{item}...] - item type can only be from folowing set [:#{PROFILE_ITEM_TYPE.join(',:')}]"
            
          end
          }
        profile_item_types_for_this_model.freeze # such that no runtime code can modify item types ;-)
        write_inheritable_attribute(:profile_item_types_for_this_model,profile_item_types_for_this_model)
        class_inheritable_reader :profile_item_types_for_this_model
        
        #profie items
        has_many :profile_items, :as => :entity_that_has_profile
       
      end
    end
    
    module InstanceMethods
      def profile_item_list
        types = profile_item_types_for_this_model
        list =[]
        types.each {|item_type|
          list.push self.profile_items.find_or_create_by_itemtype(item_type.to_s, :conditions => ["active = ?",true], :order => "DESC created_at")
        }
        list   
      end
     
      
      private
        #let private methods come here
    end
  end
end



require "ruby2ruby"

# This mixin will be included in Module.
module Chainable

  # This will "chain" a method (read: push it to a module and include it).
  # If a block is given, it will do a define_method(name, &block).
  # Maybe that is not what you want, as methods defined by def tend to be
  # faster. If that is the case, simply don't pass the block and call def
  # after chain_method instead.
  #
  # It takes the following options:
  #
  # === try_merge
  # try_merge will try merge_method for every method given and only chain if
  # that fails. Default is false.
  # 
  # === module_reuse
  # Will try to reuse the last mixin to keep the inheritance chain short.
  # Default is true.
  def chain_method(*names, &block)
    options = names.grep(Hash).inject(Chainable.default_options) do |a, b|
      a.merge names.delete(b)
    end
    names = Chainable.try_merge(self, *names, &block) if options[:try_merge]
    names.each do |name|
      name = name.to_s
      if instance_methods(false).include? name
        mod = Chainable.mixin_for(self, name, options[:module_reuse])
        Chainable.copy_method(self, mod, name)
        include mod
      end
      block ||= Proc.new { super }
      define_method(name, &block)
    end
  end

  # This will try to merge into the method, instead of chaining to it (see
  # README.rdoc). You probably don't want to use this directly but try
  #   chain_method(:some_method, :try_merge => true) { ... }
  # instead, which will fall back to chain_method if merge fails.
  def merge_method(*names, &block)
    raise ArgumentError, "no block given" unless block
    names.each do |name|
      name = name.to_s
      raise ArgumentError, "cannot merge #{name}" unless instance_methods(false).include? name
      class_eval Chainable.wrapped_source(self, name, block)
    end
  end

  # If you define a method inside a block passed to auto_chain, chain_method
  # will be called on that method right after it has been defined. This will
  # only affect methods defined for the class (or module) auto_chain has been
  # send to. See README.rdoc or spec/chainable/auto_chain_spec.rb for examples.
  #
  # auto_chain takes a hash of options, just like chain_method does.
  def auto_chain options = {}
    eigenclass = (class << self; self; end)
    eigenclass.class_eval do
      chain_method :method_added, :try_merge => false do |name|
        Chainable.skip_chain { chain_method name, options }
      end
    end
    result = yield
    eigenclass.class_eval { remove_method :method_added }
    result
  end

  # Default options for auto_chain and chain_method.
  #
  # Example usage:
  #   Chainable.default_options[:try_merge] = true
  def self.default_options
    @default_options ||= { :try_merge => false, :module_reuse => true }
  end

  # Creates mixin used by chain_method.
  def self.mixin_for(klass, name, reuse = true)
    @last_mixin ||= {}
    if reuse and klass.ancestors[1] == @last_mixin[klass]
      im = @last_mixin[klass].instance_methods(false)
      return @last_mixin[klass] unless im.include?(name.to_s)
    end
    @last_mixin[klass] = Module.new
  end

  # Used internally. See source of Chainbale#auto_chain.
  def self.skip_chain
    return if @auto_chain
    @auto_chain = true
    yield
    @auto_chain = false
  end

  # Given a class, a method name and a proc, it will try to merge the sexp
  # of the method into the sexp of the proc and return the source code (as
  # method definition). While doing so, it tries to prevent harm.
  # 
  # Raises an ArgumentError on failure.
  def self.wrapped_source(klass, name, wrapper)
    begin
      src = Ruby2Ruby.new.process wrapped_sexp(klass, name, wrapper)
      src.gsub "# do nothing", "nil"
    rescue Exception
      raise ArgumentError, "cannot merge #{name}"
    end
  end

  # The sexp part of wrapped_source. Note: In rubinius, we could use this directly
  # rather than generating the source again.
  def self.wrapped_sexp(klass, name, wrapper)
    inner = unified sexp_for(klass, name)
    outer = unified sexp_for(wrapper)
    raise if inner[2] != s(:args) or outer[2]
    inner_locals = sexp_walk(inner) { raise }
    sexp_walk(outer, inner_locals) { |e| e.replace inner[3][1] }
    s(:defn, name, s(:args), s(:scope, s(:block, outer[3])))
  end

  # Traveling a methods sexp tree. Block will be called for every super.
  def self.sexp_walk(sexp, forbidden_locals = [], &block) # :yield: sexp
    # TODO: Refactor me, I'm ugly!
    return [] unless sexp.is_a? Sexp
    local = nil
    case sexp[0]
    when :lvar then local = sexp[1]
    when :lasgn then local = sexp[1] if sexp[1].to_s =~ /^\w+$/
    when :zsuper, :super
      raise if sexp.length > 1
      yield(sexp)
    when :call then raise if sexp[2] == :eval
    end
    locals = []
    if local
      raise if forbidden_locals.include? local
      locals << local
    end
    sexp.inject(locals) { |l, e| l + sexp_walk(e, forbidden_locals, &block) }
  end

  # Unify sexp.
  def self.unified sexp
    unifier.process sexp
  end

  # Give a proc, class and method, string or sexp and get a sexp.
  def self.sexp_for a, b = nil
    require "parse_tree"
    case a
    when Class, String then ParseTree.translate(a, b)
    when Proc then ParseTree.new.parse_tree_for_proc(a)
    when Sexp then a
    else raise ArgumentError, "no sexp for #{a.inspect}"
    end
  end

  # Unifier with modifications for Ruby2Ruby. (Stolen from Ruby2Ruby.)
  def self.unifier
    return @unifier if @unifier
    @unifier = Unifier.new
    @unifier.processors.each { |p| p.unsupported.delete :cfunc }
    @unifier
  end

  # Tries merge_method on all given methods for klass.
  # Returns names of the methods that could not be merged.
  def self.try_merge(klass, *names, &wrapper)
    names.reject do |name|
      begin
        klass.class_eval { merge_method(name, &wrapper) }
        true
      rescue ArgumentError
        false
      end
    end
  end

  # Copies a method from one module to another.
  # TODO: This could be solved totally different in Rubinius.
  def self.copy_method(source_class, target_class, name)
    begin
      target_class.class_eval Ruby2Ruby.translate(source_class, name)
    rescue NameError
      # If we get here, the method is written in C or something. So let's do
      # some evil magic.
      m = source_class.instance_method name
      target_class.class_eval do
        # FIXME: the following line raises a SyntaxError in JRuby.
        #define_method(name) { |*a , &b| m.bind(self).call(*a, &b) }
        define_method(name) { |*a| m.bind(self).call(*a ) }
      end
    end
  end
    
end

Module.class_eval do
  include Chainable
  private *Chainable.instance_methods(false)
end
