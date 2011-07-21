all_rake_files = File.expand_path '../../tasks/*.rake', __FILE__

Dir[all_rake_files].each { |rakefile| load rakefile }