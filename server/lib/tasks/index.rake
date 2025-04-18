# Indexing tasks.
#
desc 'Generate the index in parallel (index, category optional).'
task :index, %i[index category] => :'index:parallel'

namespace :index do
  %i[parallel serial].each do |kind|
    desc "Generate the index in #{kind} (index, category optional)."
    task kind, %i[index category] => :application do |_, options|
      index = options.index
      category = options.category

      specific = Picky::Indexes
      specific = specific[index]    if index
      specific = specific[category] if category

      specific.index Picky::Scheduler.new(kind => true)
    end
  end
end
