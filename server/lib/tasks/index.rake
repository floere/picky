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
  
  desc "E.g. Generates a specific index table. Note: temp tables need to be there. Will generate just the index table."
  task :only, [:type, :field] => :application do |_, options|
    type, field = options.type, options.field
    Indexes.generate_index_only type.to_sym, field.to_sym
  end
  
  desc "E.g. Generates a specific index cache file. Note: temp tables need to be there. Will generate index table and cache."
  task :specific, [:type, :field] => :application do |_, options|
    type, field = options.type, options.field
    Indexes.generate_index_only type.to_sym, field.to_sym
    Indexes.generate_cache_only type.to_sym, field.to_sym
  end
  
end