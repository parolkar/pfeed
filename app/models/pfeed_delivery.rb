class PfeedDelivery < ActiveRecord::Base
  belongs_to :pfeed_receiver, :polymorphic => true
  belongs_to :pfeed_item
end
