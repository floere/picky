# Global.
#
namespace :index do

  desc "Generates the temp tables: Copies the data from the public entries."
  task :generate_temp_tables => :application do
    Indexes.take_snapshot
  end
  
  desc "rake index:tables:update"
  task :prepare => :application do
    Indexes.take_snapshot
    Indexes.configuration.index
  end
  
  desc "Generates a specific index table like field=books:title. Note: temp tables need to be there. Will generate just the index table."
  task :only => :application do
    type_and_field = ENV['FIELD'] || ENV['field']
    type, field = type_and_field.split ':'
    Indexes.generate_index_only type.to_sym, field.to_sym
  end
  
  desc "Generates a specific index cache file like field=books:title. Note: temp tables need to be there. Will generate index table and cache."
  task :specific => :application do
    type_and_field = ENV['FIELD'] || ENV['field']
    type, field = type_and_field.split ':'
    Indexes.generate_index_only type.to_sym, field.to_sym
    Indexes.generate_cache_only type.to_sym, field.to_sym
  end

end