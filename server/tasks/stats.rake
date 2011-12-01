# Very pedestrian, coder only cloc.
#
desc "Pedestrian CLOC statistics."
task :stats do
  %w|lib spec test_project test_project_sinatra|.each do |dir|
    original_dir = dir
    dir = "#{dir}/*.rb"
    dirs = 5.times.inject([dir]) do |dirs, _|
      dirs << dirs.last.gsub(%r{/*.rb}, '/**/*.rb')
    end
    total = `grep -c -e \'\s\' #{dirs.join(' ')} 2>/dev/null`.split("\n").inject(0) do |total, line|
      amount = line.split(':').last.to_i
      total + amount
    end
    puts "#{original_dir}: #{total}"
  end
end