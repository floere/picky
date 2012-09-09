# encoding: utf-8
#
require 'csv'
require 'sinatra/base'
require_relative '../lib/picky'
require_relative 'helpers'
require_relative 'source'

# Reopen class.
#
class Source

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
  # Backends::File.new,
  # Backends::SQLite.new,
  # Backends::Redis.new,
  # Backends::SQLite.new(realtime: true),
  # Backends::Redis.new(realtime: true),
]

definitions = []

# definitions << [Proc.new do
#   category :text1, weight: Picky::Weights::Constant.new
#   category :text2, weight: Picky::Weights::Constant.new
#   category :text3, weight: Picky::Weights::Constant.new
#   category :text4, weight: Picky::Weights::Constant.new
# end, :no_weights]

definitions << [Proc.new do
  category :text1
  category :text2
  category :text3
  category :text4
end, :normal]

# definitions << [Proc.new do
#   category :text1, partial: Picky::Partial::Postfix.new(from: 1)
#   category :text2, partial: Picky::Partial::Postfix.new(from: 1)
#   category :text3, partial: Picky::Partial::Postfix.new(from: 1)
#   category :text4, partial: Picky::Partial::Postfix.new(from: 1)
# end, :full_partial]

GC.enable
GC::Profiler.enable

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
    puts "All measurements in ms! (Strings/Symbols per search request)"
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
      gc_runs = []

      [queries[1, amount], queries[2, amount], queries[3, amount], queries[4, amount]].each do |queries|

        queries.prepare

        run = Search.new data
        run.terminate_early

        # Quick sanity check.
        #
        # fail if run.search(queries.each { |query| p query; break query }).ids.empty?

        GC.start
        initial_ram = ram __FILE__
        initial_symbols = Symbol.all_symbols.size

        last_gc = runs
        initial_strings = string_count

        duration = performance_of do

          # compare_strings do

            queries.each do |query|
              run.search query
            end

          # end

        end

        strings << (string_count - initial_strings)
        rams << (ram(__FILE__) - initial_ram)
        symbols << (Symbol.all_symbols.size - initial_symbols)
        gc_runs << (runs - last_gc)

        print ", "
        print "%2.4f" % (duration*1000/amount)

      end

      print "   "
      print "%5d" % rams.sum
      print "K "
      print "("
      print rams.map { |s| "%6d" % s }.join(', ')
      print ")"
      print "  %6d " % (strings.sum/amount.to_f)
      print "Strings "
      print "("
      print strings.map { |s| "%4.1f" % (s/amount.to_f) }.join(', ')
      print ")"
      print " %6d " % (symbols.sum/amount.to_f)
      print "Symbols  "
      print "("
      print symbols.map { |s| "%2.1f" % (s/amount.to_f) }.join(', ')
      print ")"
      print " %2d" % gc_runs.sum
      puts

    end

  end

end