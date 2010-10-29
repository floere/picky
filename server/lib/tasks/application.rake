# desc "Loads the application, including its configuration."
task :application => :framework do
  Loader.load_application
end