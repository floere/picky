# Indexing tasks.
#
desc "Generate the index (index, category optional)."
task :index, [:index, :category] => :application do |_, options|
  index, category = options.index, options.category

  specific = Indexes
  specific = specific[index]    if index
  specific = specific[category] if category
  specific.index
end

namespace :index do

  # Advanced usage.
  #
  # desc "Takes a snapshot, indexes, and caches in random order."
  task :randomly => :application do
    Indexes.index true
  end
  # desc "Takes a snapshot, indexes, and caches in order given."
  task :ordered => :application do
    Indexes.index false
  end

end