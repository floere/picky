# encoding: utf-8
#
require 'csv'
require 'sinatra/base'
require File.expand_path '../../lib/picky', __FILE__

class Object; def timed_exclaim(_); end end

def performance_of
  if block_given?
    code = Proc.new
    GC.disable
    t0 = Time.now
    code.call
    t1 = Time.now
    GC.enable
    (t1 - t0)
  else
    raise "#performance_of needs a block"
  end
end

class Source

  attr_reader :amount

  def initialize amount
    @amount = amount
  end

  Thing = Struct.new :id, :text1, :text2, :text3, :text4

  def each &block
    i = 0
    CSV.open('data.csv').each do |args|
      block.call Thing.new(*args)
      break if (i+=1) == @amount
    end
  end

end

with = ->(amount) do
  Source.new amount
end

include Picky

backends = [
  Backends::Memory.new,
  Backends::File.new,
  Backends::SQLite.new,
  Backends::Redis.new,
]

definition = Proc.new do
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
      query << args.shift[1..-(rand(3)+1)]
      @buffer << query.join(' ')
      break if (i+=1) == @amount
    end
  end

end

queries  = ->(complexity, amount) do
  Searches.new complexity, amount
end

xxs = Index.new :xxs, &definition
xxs.source { with[10] }
xs  = Index.new :xs,  &definition
xs.source  { with[100] }
s   = Index.new :s,   &definition
s.source   { with[1_000] }
m   = Index.new :m,   &definition
m.source   { with[10_000] }
# l   = Index.new :l,   &definition
# l.source   { with[100_000] }
# xl  = Index.new :xl,  &definition
# xl.source  { with[1_000_000] }

puts "Running tests"

backends.each do |backend|

  puts
  puts "All measurements in ms!"
  puts backend.class

  Indexes.each do |data|

    if backend == backends.first
      data.prepare
    end

    data.backend backend
    data.clear
    data.cache
    data.load

    amount = 50

    print "%7d" % data.source.amount

    [queries[1, amount], queries[2, amount], queries[3, amount], queries[4, amount]].each do |queries|

      queries.prepare

      run = Search.new data

      # Quick sanity check.
      #
      # results = run.search(queries.each { |query| p query; break query }).ids
      # p(results) && fail if results.empty?

      duration = performance_of do

        queries.each do |query|
          run.search query
        end

      end

      print ", "
      print "%2.4f" % (duration*1000/amount)

    end

    puts

  end

end