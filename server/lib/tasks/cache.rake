namespace :cache do
  
  # Move to index namespace.
  #
  
  # desc "Generates the index cache files."
  # task :generate => :application do
  #   Indexes.generate_caches
  #   puts "Caches generated."
  # end

  # desc "Generates a specific index cache file like field=books:title. Note: Index tables need to be there. Will generate just the cache."
  # task :only => :application do
  #   type_and_field = ENV['FIELD'] || ENV['field']
  #   type, field = type_and_field.split ':'
  #   Indexes.generate_cache_only type.to_sym, field.to_sym
  # end
  
  
  # desc 'Checks the index cache files'
  # task :check => :application do
  #   Indexes.check_caches
  #   puts "All caches look ok."
  # end
  
  
  # desc "Removes the index cache files."
  # task :clear => :application do
  #   Indexes.clear_caches
  #   puts "All index cache files removed."
  # end
  
  
  # desc 'Backup the index cache files'
  # task :backup => :application do
  #   Indexes.backup_caches
  #   puts "Index cache files moved to the backup directory"
  # end
  
  # desc 'Restore the index cache files'
  # task :restore => :application do
  #   Indexes.restore_caches
  #   puts "Index cache files restored from the backup directory"
  # end
  
end
