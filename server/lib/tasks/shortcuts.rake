desc "Shortcut for index:generate."
task :index => :application do
  Rake::Task[:'index:generate'].invoke
end

desc "shortcut for server:start"
task :start do
  Rake::Task[:'server:start'].invoke
end
desc "shortcut for server:stop"
task :stop do
  Rake::Task[:'server:stop'].invoke
end