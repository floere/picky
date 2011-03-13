# Shortcut tasks.
#

desc "Generate the index (random order)."
task :index => :application do
  Rake::Task[:'index:randomly'].invoke
end

desc "Try the given text in the indexer/query (index:category optional)."
task :try, [:text, :index, :category] => :application do |_, options|
  text, index, category = options.text, options.index, options.category

  Rake::Task[:'try:both'].invoke text, index, category
end

desc "Application summary."
task :stats do
  Rake::Task[:'stats:app'].invoke
end
desc "Analyze your indexes (needs rake index)."
task :analyze do
  Rake::Task[:'stats:analyze'].invoke
end

desc "Start the server."
task :start do
  Rake::Task[:'server:start'].invoke
end
desc "Stop the server."
task :stop do
  Rake::Task[:'server:stop'].invoke
end