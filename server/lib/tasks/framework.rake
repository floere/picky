# desc "Loads the framework."
#
# Note: This is used by tasks to load the framework as a dependency.
#
task :framework do
  require_relative '../picky'
end