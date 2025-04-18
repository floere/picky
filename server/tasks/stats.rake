# Very pedestrian, coder only cloc.
#
desc 'Pedestrian CLOC statistics.'
task :stats do
  libs  = 0.0
  specs = 0.0
  %w|lib spec test_project|.each do |dir|
    original_dir = dir
    dir = "#{dir}/*.rb"
    dirs = 5.times.inject([dir]) do |dirs, _|
      dirs << dirs.last.gsub(%r{/*.rb}, '/**/*.rb')
    end
    total = `grep -c -e \'\s\' #{dirs.join(' ')} 2>/dev/null`.split("\n").inject(0) do |total, line|
      amount = line.split(':').last.to_i
      total + amount
    end
    if original_dir == 'lib'
      libs += total
    else
      specs += total
    end
    puts "#{original_dir}: #{total}"
  end
  puts
  puts "Code/Test Ratio: 1:#{(specs/libs).round(1)}"
end