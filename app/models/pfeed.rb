class Pfeed < ActiveRecord::Base

  before_validation_on_create :pack_data
  serialize :data, Hash
  serialize :participants, Array
   
  belongs_to :originator, :polymorphic => true
  belongs_to :participant, :polymorphic => true
  
  
    
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
