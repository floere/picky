# Indexing tasks.
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
  #
  # Note: Hidden since it is only needed by pro users.
  #
  # desc "Generate the data snapshots (intermediate table on a DB source)"
  task :generate_snapshots => :application do
    Indexes.take_snapshot
  end

  desc "Generates a specific index from index snapshots (category optional)."
  task :specific, [:index, :category] => :application do |_, options|
    index, category = options.index, options.category
    specific_index = Indexes.find index.to_sym, (category && category.to_sym)
    specific_index.prepare
    specific_index.cache
  end

end