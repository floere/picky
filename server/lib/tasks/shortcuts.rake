desc "Shortcut for index:generate."
task :index => :application do
  Rake::Task[:'index:generate'].invoke
end

desc "Shortcut for try:both"
task :try, [:text, :type_and_field] => :application do |_, options|
  text, type_and_field = options.text, options.type_and_field
  
  Rake::Task[:'try:both'].invoke text, type_and_field
end

desc "shortcut for server:start"
task :start do
  Rake::Task[:'server:start'].invoke
end
desc "shortcut for server:stop"
task :stop do
  Rake::Task[:'server:stop'].invoke
end