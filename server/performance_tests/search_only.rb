require 'csv'
require 'sinatra/base'
require_relative '../lib/picky'

# ruby search_only.rb xxs (index size) 100 (amount of queries)
#
size   = ARGV[0].to_sym
amount = ARGV[1] && ARGV[1].to_i || 10

data = Picky::Index.new size do
  category :text1
  category :text2
  category :text3
  category :text4
end

class Searches

  def initialize complexity, amount
    @complexity, @amount = complexity, amount
  end

  def each &block
    @buffer.each &block
  end

  def prepare
    @buffer = []

    i = 0
    CSV.open('data.csv').each do |args|
      _, *args = args
      args = args + [args.first]
      query = []
      (@complexity-1).times do
        query << args.shift
      end
      query << args.shift
      @buffer << query.join(' ')
      break if (i+=1) == @amount
    end
  end

end

queries  = ->(complexity, amount) do
  Searches.new complexity, amount
end

# You need to create the indexes first.
#
data.clear
data.load

require 'ruby-prof'
RubyProf.start
RubyProf.pause

# Run queries.
#
[queries[1, amount], queries[2, amount], queries[3, amount], queries[4, amount]].each do |queries|

  queries.prepare

  run = Picky::Search.new data
  run.terminate_early
  
  queries.each do |query|
    RubyProf.resume
    run.search query
    RubyProf.pause
  end
  
end

result = RubyProf.stop

filename = "#{Dir.pwd}/20#{Time.now.strftime("%y%m%d%H%M")}-ruby-prof-results-#{size}-#{amount}.html"
File.open filename, 'w' do |file|
  RubyProf::GraphHtmlPrinter.new(result).print(file)
end

printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, :min_percent => 2)

puts "open #{filename}"