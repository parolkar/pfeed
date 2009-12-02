class PfeedItem < ActiveRecord::Base

  #before_validation_on_create :pack_data
  serialize :data, Hash
  serialize :participants, Array
   
  belongs_to :originator, :polymorphic => true
  belongs_to :participant, :polymorphic => true

  has_many :pfeed_deliveries, :dependent => :destroy   
  
  attr_accessor :temp_references # this is an temporary Hash to hold references to temporary Objects 
  
  CUSTOM_CLASSES = {}
  def self.log(ar_obj,method_name,method_name_in_past_tense,returned_result,*args_supplied_to_method,&block_supplied_to_method)
     #puts "#{ar_obj.class.to_s},#{method_name},#{method_name_in_past_tense},#{returned_result},#{args_supplied_to_method.length}"

    # optional :if => :test, or :unless => :test
    if ar_obj.respond_to?(:pfeed_conditions_hash)
      if (conds = ar_obj.pfeed_conditions_hash[method_name.to_sym])
        if if_cond = conds[:if]
          return unless ar_obj.send(if_cond)
        end
        if unless_cond = conds[:unless]
          return if !ar_obj.send(unless_cond)
        end
      end
    end
     
      temp_references = Hash.new
      temp_references[:originator] = ar_obj
      temp_references[:participant] = nil
      temp_references[:participant] = args_supplied_to_method[0] if args_supplied_to_method &&  args_supplied_to_method.length >= 1 && args_supplied_to_method[0].class.superclass.to_s == "ActiveRecord::Base"

      pfeed_class_name = "#{ar_obj.class.to_s.underscore}_#{method_name_in_past_tense}".camelize # may be I could use .classify
      contstructor_options = { :originator_id => temp_references[:originator].id , :originator_type => temp_references[:originator].class.to_s , :participant_id => (temp_references[:participant] ? temp_references[:participant].id : nil) , :participant_type => (temp_references[:participant] ? temp_references[:participant].class.to_s : nil) } # there is a reason why I didnt use {:originator => temp_references[:originator]} , if originator is new record it might get saved here un intentionally


      p_item = if (klass = CUSTOM_CLASSES[pfeed_class_name]).nil?
        retried = false
        begin
          #puts "Attempting to create object of  #{pfeed_class_name} "
          klass = pfeed_class_name.constantize
          (CUSTOM_CLASSES[pfeed_class_name] = klass).new(
            contstructor_options.merge(:temp_references => temp_references))
        rescue NameError
          unless retried
            CUSTOM_CLASSES[pfeed_class_name] = false
            retried = true
            pfeed_class_name = "Pfeeds::"+pfeed_class_name
            retry
          end
          #puts "could not find class #{pfeed_class_name} , hence using default Pfeed"
          PfeedItem.new(contstructor_options) 
        end   
      else
        if klass == false
          PfeedItem.new(contstructor_options) 
        else
          klass.new(contstructor_options) 
        end
      end

      p_item.pack_data(method_name,method_name_in_past_tense,returned_result,*args_supplied_to_method,&block_supplied_to_method)


      p_item.save
      #puts "Trying to deliver to #{ar_obj}  #{ar_obj.pfeed_audience_hash[method_name.to_sym]}"
      p_item.attempt_delivery(ar_obj,ar_obj.pfeed_audience_hash[method_name.to_sym])   # attempting the delivery of the feed
  end  
  
  @@dj = (defined? Delayed) == "constant" && (instance_methods.include? 'send_later') #this means Delayed_job exists , so make use of asynchronous delivery of pfeed

  def attempt_delivery (ar_obj,method_name_arr)
    return if method_name_arr.empty?

    if @@dj
      send_later(:deliver,ar_obj,method_name_arr)  
    else  # regular instant delivery
      send(:deliver,ar_obj,method_name_arr)    
    end
  end

  def deliver(ar_obj,method_name_arr)
    method_name_arr.map { |method_name|
      ar_obj.send(method_name)
    }.flatten.uniq.map {|o| deliver_to(o) }.compact
  end

  def deliver_to(result_obj)
    return nil unless (result_obj != nil && result_obj.is_pfeed_receiver)

    if !result_obj.new_record?
      delivery = PfeedDelivery.new
      delivery.pfeed_item = self
      delivery.pfeed_receiver = result_obj
      delivery.save!
    end

    return result_obj
  end

  def accessible?
    true 
  end

  def view_template_name 
    "#{self.class.to_s.underscore}".split("/").last
  end
  
  def audience
    # return list of objects to whom feed gets delivered
  end
  
  def pack_data(method_name,method_name_in_past_tense,returned_result,*args_supplied_to_method,&block_supplied_to_method) 
    self.data = {} if ! self.data
    action_string = method_name_in_past_tense.humanize.downcase
    hash_to_be_merged = {:action_string => action_string}
    
    self.data.merge!  hash_to_be_merged
  end
  
  def guess_identification(ar_obj)
    possible_attributes = ["username","login","name","company_name","first_name","last_name","login_name","login_id","given_name","nick_name","nick","short_name"]
    
    possible_attributes = self.data[:config][:identifications] + possible_attributes if self.data[:config] && self.data[:config][:identifications] && self.data[:config][:identifications].is_a?(Array)
    matched_name = ar_obj.attribute_names & possible_attributes # intersection of two sets
    
    identi = nil
    
    identi =  ar_obj.read_attribute(matched_name[0]) if identi == nil && matched_name.length > 0
    identi =  "#{ar_obj.class.to_s}(\##{ar_obj.id})"  if identi == nil || identi.blank?
    
    return identi
  rescue
    return "UNKNOWN"  
  end  
end
