desc "Shortcut for indexing and caching."
task :index => :application do
  Indexes.index
end

desc "shortcut for server:start"
task :start do
  Rake::Task[:'server:start'].invoke
end
desc "shortcut for server:stop"
task :stop do
  Rake::Task[:'server:stop'].invoke
end