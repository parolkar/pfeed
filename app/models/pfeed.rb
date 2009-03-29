class Pfeed < ActiveRecord::Base

  before_validation_on_create :pack_data
  serialize :data, Hash
  
  
  belongs_to :originator, :polymorphic => true
  belongs_to :participant, :polymorphic => true
  
  def accessible?
    true 
  end
  def view_template 
   
  end
  
  def pack_data 
    self.data = {
      :key1 => "value"
    }
   end
end
