module ParolkarInnovationLab
  module SocialNet
    def self.included(base)
      base.extend ParolkarInnovationLab::SocialNet::ClassMethods
    end
    
    module ClassMethods
      def has_profile_items items_array
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