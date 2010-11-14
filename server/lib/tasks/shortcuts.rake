desc "Generate the index (random order)."
task :index => :application do
  Rake::Task[:'index:randomly'].invoke
end

desc "Try the given text in the indexer/query (index:field optional)."
task :try, [:text, :index_and_field] => :application do |_, options|
  text, index_and_field = options.text, options.index_and_field
  
  Rake::Task[:'try:both'].invoke text, index_and_field
end

desc "Start the server."
task :start do
  Rake::Task[:'server:start'].invoke
end
desc "Stop the server."
task :stop do
  Rake::Task[:'server:stop'].invoke
end