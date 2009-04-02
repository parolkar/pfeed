#snippet: https://gist.github.com/89e92409ca9016d2d919

module ParolkarInnovationLab
  module SocialNet
    def self.included(base)
      base.extend ParolkarInnovationLab::SocialNet::ClassMethods
    end
    
    module ClassMethods
                  
      def emits_pfeeds_for method_name_array
        include ParolkarInnovationLab::SocialNet::InstanceMethods
       
        method_name_array.each { |method_name|
          method, symbol = method_name.to_s.split /(\!|\?)/
          symbol = '' if symbol.nil?
                    
          method_to_define = method + '_with_pfeed' + symbol
          method_to_be_called = method + '_without_pfeed' + symbol
          eval %[
               
             module ::ParolkarInnovationLab::SocialNet::PfeedTemp::#{self.to_s} 
              def #{method_to_define}(*a, &b)
                returned_result = #{method_to_be_called}(*a , &b)
                method_name_in_past_tense = "#{ParolkarInnovationLab::SocialNet::PfeedUtils.attempt_pass_tense(method)}"
                PfeedItem.log(self,"#{method_name}",method_name_in_past_tense,returned_result,*a,&b) 
                returned_result
              end
             end    
          ] 
            
        }
        
        #TODO : Pfeed.log(self,"#{method_name}",method_name_in_past_tense,returned_result,*a,*b)  : this is to be done in a different thread in bg to boost performance & also needs exception handling such that parent call never breaks
        
        include "::ParolkarInnovationLab::SocialNet::PfeedTemp::#{self.to_s}".constantize # why this? because "define_method((method + '_with_pfeed' + symbol).to_sym) do |*a , &b|" generates syntax error in ruby < 1.8.7 
        
        method_name_array.each { |method_name|
          method, symbol = method_name.to_s.split /(\!|\?)/
          symbol = '' if symbol.nil?
          alias_method_chain (method + symbol), :pfeed
        }
          
      end
    end
    
    module PfeedTemp
      # Required for temporarily injecting new methods
    end  
    module InstanceMethods
    
      private
        #let private methods come here
    end
  end
end



