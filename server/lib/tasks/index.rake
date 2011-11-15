# Indexing tasks.
#
desc "Generate the index (index, category optional)."
task :index, [:index, :category] => :application do |_, options|
  index, category = options.index, options.category

  specific = Picky::Indexes
  specific = specific[index]    if index
  specific = specific[category] if category
  specific.index
end

namespace :index do

  task :randomly => :application do
    Picky::Indexes.index true
  end
  task :ordered => :application do
    Picky::Indexes.index false
  end

end