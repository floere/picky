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
  
  desc "Generates a specific index from index snapshots (category optional)."
  task :specific, [:index, :category] => :application do |_, options|
    index, category = options.index, options.category
    Indexes.generate_index_only index.to_sym, category && category.to_sym
    Indexes.generate_cache_only index.to_sym, category && category.to_sym
  end
  
  desc 'Checks the index files for files that are suspiciously small or missing.'
  task :check => :application do
    Indexes.check_caches
    puts "All indexes look ok."
  end
  
end