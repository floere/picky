desc "Loads the application, including its configuration."
task :application => :framework do
  puts "Running rake task 'application'."
  Loader.load_application
end