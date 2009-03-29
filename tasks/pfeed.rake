namespace :pfeed do
    
    desc 'Sets up parolkar\'s pfeed plugin '
    task :setup do
      
      raise 'pfeed plugin was only tested on unix & windows' if ! Rake.application.unix? &&  ! Rake.application.windows?
      
      
      
      welcome_screen
     
    end
 
    def migration_timestamp
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    end  
    
    def welcome_screen
    
    mesg = <<HERE
Congratulations for setting the plugin! There are few things to remember here...


HERE

    puts mesg      
    end
    
end
