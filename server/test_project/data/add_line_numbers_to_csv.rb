def add_line_numbers_to(file_name)
  File.open(File.expand_path('with_line_numbers.out', __dir__), 'w') do |output|
    File.open(file_name) do |file|
      i = 1
      lines = file.readlines
      width = Math.log(lines.size, 10).round
      formatting = "%#{width}d"
      lines.each do |line|
        output.write "#{formatting % i},#{line}"
        i += 1
      end
    end
  end
end

add_line_numbers_to ARGV[0]
