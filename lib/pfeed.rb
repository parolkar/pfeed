#snippet: https://gist.github.com/89e92409ca9016d2d919

module ParolkarInnovationLab
  module SocialNet
    def self.included(base)
      base.extend ParolkarInnovationLab::SocialNet::ClassMethods
    end
    
    module ClassMethods
      
      def pfeed_create_block # hack from http://blog.jayfields.com/2006/07/ruby-eval-with-binding.html
          Proc.new {}
      end
      
      def emits_pfeeds_for method_name_array
        include ParolkarInnovationLab::SocialNet::InstanceMethods
       
        method_name_array.each { |method_name|
          method, symbol = method_name.to_s.split /(\!|\?)/
          symbol = '' if symbol.nil?
                    
          method_to_define = method + '_with_pfeed' + symbol
          method_to_be_called = method + '_without_pfeed' + symbol
          eval %[
               
             module ::ParolkarInnovationLab::SocialNet::#{self.to_s} 
              def #{method_to_define}(*a, &b)
                returned_result = #{method_to_be_called}(*a , &b)
                puts "#{ParolkarInnovationLab::SocialNet::PfeedUtils.attempt_pass_tense(method)}"
                returned_result
              end
             end    
          ] 
         
          
          include "::ParolkarInnovationLab::SocialNet::#{self.to_s}".constantize # why this? because "define_method((method + '_with_pfeed' + symbol).to_sym) do |*a , &b|" generates syntax error in ruby < 1.8.7 
          
                
          alias_method_chain (method + symbol), :pfeed
          }
       
       
      end
    end
    
    module InstanceMethods
    
      
      
      private
        #let private methods come here
    end
  end
end



