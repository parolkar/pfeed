class PfeedItem < ActiveRecord::Base

  before_validation_on_create :pack_data
  serialize :data, Hash
  serialize :participants, Array
   
  belongs_to :originator, :polymorphic => true
  belongs_to :participant, :polymorphic => true

  has_many :pfeed_deliveries
  
  def self.log(ar_obj,method_name,method_name_in_past_tense,returned_result,*args_supplied_to_method,&block_supplied_to_method)
     puts "#{ar_obj.class.to_s},#{method_name},#{method_name_in_past_tense},#{returned_result},#{args_supplied_to_method.length}"
     
     @originator = ar_obj
     @participant = nil
     @participant = args_supplied_to_method[0] if args_supplied_to_method &&  args_supplied_to_method.length >= 1 && args_supplied_to_method[0].class.superclass.to_s == "ActiveRecord::Base"
       
     pfeed_class_name = "#{ar_obj.class.to_s.underscore}_#{method_name_in_past_tense}".camelize # may be I could use .classify
     pfeed_class_name = "Pfeeds::"+pfeed_class_name
     contstructor_options = { :originator_id => @originator.id , :originator_type => @originator.class.to_s , :participant_id => (@participant ? @participant.id : nil) , :participant_type => (@participant ? @participant.class.to_s : nil) } # there is a reason why I didnt use {:originator => originator} , if originator is new record it might get saved here un intentionally
     
       
     p_item =  nil
     begin
       p_item =  pfeed_class_name.constantize.new(contstructor_options) 
     rescue NameError
       puts "could not find class #{pfeed_class_name} , hence using default Pfeed"
       p_item = PfeedItem.new(contstructor_options) 
     end   
     
     p_item.save
     puts "Trying to deliver to #{ar_obj}  #{ar_obj.pfeed_audience_hash[method_name.to_sym]}"
     p_item.deliver(ar_obj,ar_obj.pfeed_audience_hash[method_name.to_sym])
     
  end  

  def deliver(ar_obj,method_name_arr)
    all_receivers = Array.new

    method_name_arr.each { |method_name|
      result_obj = ar_obj.send(method_name)
      if result_obj.is_a?(Array)
         result_obj.each { |result_ar_obj| all_receivers.push(result_ar_obj) if (result_ar_obj.is_pfeed_receiver && !all_receivers.include?(result_ar_obj))}
      else
         all_receivers.push(result_obj) if (result_obj.is_pfeed_receiver && !all_receivers.include?(result_obj))
      end	

    }  

    all_receivers.each { |r_obj|
      
      delivery = PfeedDelivery.new
      
      if ! r_obj.new_record?
        delivery.pfeed_item = self
        delivery.pfeed_receiver = r_obj
        delivery.save!
      end
    }

  end
  def accessible?
    true 
  end
  def view_template 
    "{view}"
  end
  
  def audience
    # return list of objects to whom feed gets delivered
  end
  
  def pack_data 
    self.data = {
      :key1 => "value"
    }
  end
end
