# Global.
#
namespace :index do
  
  # Not necessary anymore.
  #
  # namespace :directories do
  #   desc 'Creates the directory structure for the indexes.'
  #   task :make => :application do
  #     Indexes.create_directory_structure
  #     puts "Directory structure generated."
  #   end
  # end
  
  desc "Takes a snapshot, indexes, and caches."
  task :generate => :application do
    Indexes.index
  end
  
  desc "Generates the index snapshots."
  task :generate_snapshots => :application do
    Indexes.take_snapshot
  end
  
  # desc "E.g. Generates a specific index table. Note: intermediate indexes need to be there."
  # task :only, [:type, :field] => :application do |_, options|
  #   type, field = options.type, options.field
  #   Indexes.generate_index_only type.to_sym, field.to_sym
  # end
  
  desc "Generates a specific index from index snapshots."
  task :specific, [:type, :field] => :application do |_, options|
    type, field = options.type, options.field
    Indexes.generate_index_only type.to_sym, field.to_sym
    Indexes.generate_cache_only type.to_sym, field.to_sym
  end
  
end