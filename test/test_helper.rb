ENV['RAILS_ENV'] = 'test'

require 'rubygems'
require 'active_record'
require 'action_controller'
require 'active_support'

def __DIR__
  File.dirname(__FILE__)
end
require "#{__DIR__}/../init"

require 'riot'

# ?
class String
  unless methods.include? 'normalize'
    def normalize *args
      self
    end
  end
end

begin # infletionist dependency
  require "#{__DIR__}/../../inflectionist/init"
rescue LoadError
  puts "\n\n\nplease install the inflectionist plugin\n\n\n"
  exit(1)
end


def load_schema
  Dir["#{__DIR__}/../app/models/**/*.rb"].each { |f| require f }

  ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database => ":memory:"
  )

  ActiveRecord::Schema.define do
    create_table "emitters", :force => true do |t|
      t.string 'name'
    end
      
    create_table "pfeed_items", :force => true do |t|
      t.string  "type"
      t.integer "originator_id"
      t.string  "originator_type"
      t.integer "participant_id"
      t.string  "participant_type"
      t.text    "data"
      t.datetime 'expiry'
      t.timestamps
    end

    create_table "pfeed_deliveries", :force => true do |t|
      t.integer :pfeed_receiver_id
      t.integer :pfeed_receiver_type
      t.integer :pfeed_item_id
      t.timestamps
    end
  end
end
