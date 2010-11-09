# Global.
#
namespace :index do
  
  desc "Takes a snapshot, indexes, and caches in random order."
  task :randomly => :application do
    Indexes.index true
  end
  desc "Takes a snapshot, indexes, and caches in order given."
  task :ordered => :application do
    Indexes.index false
  end
  
  # desc "Generates the index snapshots."
  task :generate_snapshots => :application do
    Indexes.take_snapshot
  end
  
  desc "Generates a specific index from index snapshots."
  task :specific, [:type, :field] => :application do |_, options|
    type, field = options.type, options.field
    Indexes.generate_index_only type.to_sym, field.to_sym
    Indexes.generate_cache_only type.to_sym, field.to_sym
  end
  
  desc 'Checks the index files for files that are suspiciously small or missing.'
  task :check => :application do
    Indexes.check_caches
    puts "All indexes look ok."
  end
  
end