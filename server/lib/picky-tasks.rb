all_rake_files = File.expand_path File.join(File.dirname(__FILE__), 'tasks', '*.rake')

Dir[all_rake_files].each do |rakefile|
  next if rakefile =~ /spec\.rake$/
  load rakefile
end