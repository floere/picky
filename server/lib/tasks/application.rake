# desc "Loads the application, including its configuration."
#
# Note: This is used by tasks to load the application (and the framework) as a dependency.
#
task :application => :framework do
  Picky::Loader.load_application
end