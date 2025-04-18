require 'csv'
require 'sinatra/base'
require_relative '../lib/picky'

# ruby profile.rb xxs (index size) 100 (amount of queries)
#
size   = begin
  ARGV[0].to_sym
rescue StandardError
  puts('This script needs an index size as first argument.') && exit(1)
end
amount = ARGV[1]&.to_i || 10

data = Picky::Index.new size do
  category :text1
  category :text2
  category :text3
  category :text4
end

require_relative 'searches'

# You need to create the indexes first.
#
data.clear
data.load

# Run queries.
#
Searches.series_for(amount).each do |queries|
  queries.prepare

  run = Picky::Search.new data
  # run.max_allocations 1
  # run.terminate_early

  # Required here to avoid RubyProf early start.
  #
  require 'ruby-prof'
  begin
    RubyProf.start
  rescue StandardError
    'RubyProf docs for the fail!'
  end
  RubyProf.pause # Does not work.

  queries.each do |query|
    run.search query
  end

  RubyProf.pause
end

result = RubyProf.stop
result.eliminate_methods!([/(Searches|CSV)#.+/])

filename = "#{Dir.pwd}/20#{Time.now.strftime('%y%m%d%H%M')}-ruby-prof-results-#{size}-#{amount}"
html = "#{filename}.html"
viz  = "#{filename}.viz"
File.open html, 'w' do |file|
  RubyProf::CallStackPrinter.new(result).print file
  # RubyProf::GraphHtmlPrinter.new(result).print file
end
File.open viz, 'w' do |file|
  RubyProf::DotPrinter.new(result).print file
end

printer = RubyProf::GraphPrinter.new result
printer.print $stdout, min_percent: 2

command = "open #{html}"
puts command
`#{command}`

command = "twopi -Tsvg -Goverlap=scale -orendered.svg #{viz}; open -a 'Google Chrome' rendered.svg"
puts command
`#{command}`
