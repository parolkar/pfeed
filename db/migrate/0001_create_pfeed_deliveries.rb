class CreatePfeedDeliveries < ActiveRecord::Migration
  def self.up
   
    create_table :pfeed_deliveries do |t|
     t.integer :pfeed_receiver_id
     t.string :pfeed_receiver_type
     t.integer :pfeed_item_id
     t.timestamps
   end
  end

  def self.down
     drop_table :pfeed_deliveries
  end
end
