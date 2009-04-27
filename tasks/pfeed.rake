namespace :pfeed do
    
    desc 'Sets up parolkar\'s pfeed plugin '
    task :setup do
       root = "#{Rails.root}"
      raise 'pfeed plugin was only tested on unix & windows' if ! Rake.application.unix? &&  ! Rake.application.windows?
      
      if ! File.exists?("#{root}/vendor/plugins/inflectionist")
        puts "Inflectionist plugin is required by pfeed, while you dont seem to have it installed \n Attempting to install..."
        system "#{root}/script/plugin install git://github.com/parolkar/inflectionist.git "
      end
      
      raise '...something went wrong please install http://github.com/parolkar/inflectionist first!' if ! File.exists?("#{root}/vendor/plugins/inflectionist")
      
      
      files_to_be_copied = [
        {:source => "/vendor/plugins/pfeed/db/migrate/0000_create_pfeed_items.rb", :target => "/db/migrate/#{migration_timestamp}_create_pfeed_items.rb" },
         {:source => "/vendor/plugins/pfeed/db/migrate/0001_create_pfeed_deliveries.rb", :target => "/db/migrate/#{migration_timestamp}_create_pfeed_deliveries.rb" }
        ]
      
     
      FileUtils.mkdir_p("#{root}/db/migrate") unless File.exists?("#{root}/db/migrate")
      files_to_be_copied.each {|ftbc|
        FileUtils.cp_r(root+ftbc[:source], root+ftbc[:target]) #:force => true)
        puts "Created : #{ftbc[:target]}"
      }
      
      puts "Running \"rake db:migrate\" for you..."
      Rake::Task["db:migrate"].invoke
      
     
      
      welcome_screen
     
    end
 
    def migration_timestamp
      sleep (1)
      Time.now.utc.strftime("%Y%m%d%H%M%S")
      
    end  
    
    def welcome_screen
    
    mesg = <<HERE
Congratulations for setting the plugin! 


HERE

    puts mesg      
    end
    
end
