class CreatePfeedItems < ActiveRecord::Migration
   def self.up
   create_table :pfeed_items do |t|
     t.string  :type
     t.integer :originator_id
     t.string :originator_type
     t.integer :participant_id
     t.string :participant_type
     t.text   :data
     t.datetime :expiry
     t.timestamps
   end
 end

 def self.down
   drop_table :pfeed_items
 end
end
