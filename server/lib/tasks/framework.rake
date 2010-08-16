desc "Loads the framework."
task :framework do
  require File.expand_path(File.join(File.dirname(__FILE__), '..', 'picky'))
end