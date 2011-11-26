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

backends = [
  Backends::Memory.new,
  Backends::File.new,
  Backends::SQLite.new,
  Backends::Redis.new,
]

definitions = []

definitions << [Proc.new do
  category :text1
  category :text2
  category :text3
  category :text4
end, :normal]

definitions << [Proc.new do
  category :text1, weights: Picky::Partial::Postfix.new(from: 1)
  category :text2, weights: Picky::Partial::Postfix.new(from: 1)
  category :text3, weights: Picky::Partial::Postfix.new(from: 1)
  category :text4, weights: Picky::Partial::Postfix.new(from: 1)
end, :full_partial]

definitions << [Proc.new do
  category :text1, weights: Picky::Weights::Constant.new
  category :text2, weights: Picky::Weights::Constant.new
  category :text3, weights: Picky::Weights::Constant.new
  category :text4, weights: Picky::Weights::Constant.new
end, :no_weights]

ram = ->() do
  # Demeter is rotating in his grave :D
  #
  `ps u`.split("\n").select { |line| line.include? __FILE__ }.first.split(/\s+/)[5].to_i
end
string = ->() do
  i = 0
  ObjectSpace.each_object(String) do |s|
    # puts s
    i += 1
  end
  i
end
GC.enable

definitions.each do |definition, description|

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

  puts
  puts
  puts "Running tests with definition #{description}."

  backends.each do |backend|

    puts
    puts "All measurements in ms!"
    puts backend.class

    Indexes.each do |data|

      data.prepare if backend == backends.first

      data.backend backend
      data.clear
      data.cache
      data.load

      amount = 50

      print "%7d" % data.source.amount

      rams = []
      strings = []
      symbols = []

      [queries[1, amount], queries[2, amount], queries[3, amount], queries[4, amount]].each do |queries|

        queries.prepare

        run = Search.new data

        # Quick sanity check.
        #
        # fail if run.search(queries.each { |query| p query; break query }).ids.empty?

        GC.start
        initial_ram = ram.call
        initial_strings = string.call
        initial_symbols = Symbol.all_symbols.size

        duration = performance_of do

          queries.each do |query|
            run.search query
          end

        end

        rams << (ram.call - initial_ram)
        strings << (string.call - initial_strings)
        symbols << (Symbol.all_symbols.size - initial_symbols)

        print ", "
        print "%2.4f" % (duration*1000/amount)

      end

      print "   "
      print "%5d" % rams.sum
      print "K "
      print "("
      print rams.map { |s| "%6d" % s }.join(', ')
      print ")"
      print "  %6d " % strings.sum
      print "Strings "
      print "("
      print strings.map { |s| "%6d" % s }.join(', ')
      print ")"
      print " %6d " % symbols.sum
      print "Symbols  "
      print "("
      print symbols.map { |s| "%6d" % s }.join(', ')
      print ")"
      puts

    end

  end

end