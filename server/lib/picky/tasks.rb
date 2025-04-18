all_rake_files = File.expand_path '../tasks/*.rake', __dir__

Dir[all_rake_files].each { |rakefile| load rakefile }