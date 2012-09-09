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

  def prepare
    @buffer = []
    i = 0
    CSV.open('data.csv').each do |args|
      @buffer << Thing.new(*args)
      break if (i+=1) == @amount
    end
  end

  def each up_to = nil, &block
    @buffer[0..(up_to || amount)].each &block
  end

end

include Picky

backends = [
  ["realtime Redis", Backends::Redis.new(realtime: true), 100],
  ["realtime SQLite", Backends::SQLite.new(realtime: true), 100],
  ["standard Redis", Backends::Redis.new, 200],
  ["standard SQLite", Backends::SQLite.new, 200],
  ["standard File", Backends::File.new, 300],
  ["standard Memory", Backends::Memory.new, 500],
]

constant_weight = Picky::Weights::Constant.new
no_partial      = Picky::Partial::None.new
full_partial    = Picky::Partial::Postfix.new from: 1
double_meta     = Picky::Similarity::DoubleMetaphone.new 3

definitions = []

categories = 4

definitions << [Proc.new do
  1.upto(categories).each do |i|
    category :"text#{i}", weight: constant_weight, partial: no_partial
  end
end, :no_weights_no_partial_default_similarity]

definitions << [Proc.new do
  1.upto(categories).each do |i|
    category :"text#{i}", weight: constant_weight
  end
end, :no_weights_default_partial_default_similarity]

definitions << [Proc.new do
  1.upto(categories).each do |i|
    category :"text#{i}"
  end
end, :default_weights_default_partial_default_similarity]

definitions << [Proc.new do
  1.upto(categories).each do |i|
    category :"text#{i}", partial: full_partial
  end
end, :default_weights_full_partial_no_similarity]

definitions << [Proc.new do
  1.upto(categories).each do |i|
    category :"text#{i}", similarity: double_meta
  end
end, :default_weights_default_partial_double_metaphone_similarity]

definitions << [Proc.new do
  1.upto(categories).each do |i|
    category :"text#{i}", partial: full_partial, similarity: double_meta
  end
end, :default_weights_full_partial_double_metaphone_similarity]

puts
puts
puts "All measurements in processed per second!"

source = Source.new 500
source.prepare

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
runs = ->() do
  GC::Profiler.result.match(/\d+/)[0].to_i
end
GC.enable
GC::Profiler.enable

backends.each do |backend_description, backend, amount|

  puts
  print "Running tests with #{backend_description} with #{"%5d" % amount} indexed:"
  puts  "           add/index |    dump |   total      RAM/string/symbols per indexed"

  definitions.each do |definition, description|

    print "%65s" % description
    print ": "

    Indexes.clear_indexes

    data = Index.new :m, &definition
    data.backend backend

    GC.start
    initial_ram = ram.call
    initial_strings = string.call
    initial_symbols = Symbol.all_symbols.size

    last_gc = runs.call

    add_duration = performance_of do
      source.each(amount) do |thing|
        data.add thing # direct
      end
    end

    current_ram = ram.call - initial_ram
    strings = string.call
    symbols = Symbol.all_symbols.size

    print "%7.0f" % (amount / add_duration)
    print " | "

    dump_duration = performance_of do
      data.dump
    end

    print "%7.0f" % (amount / dump_duration)
    print " | "
    print "%7.0f" % (amount / (add_duration + dump_duration))
    print "   "
    print "%5d" % (current_ram / amount)
    print "K  "
    print "%6.1f" % ((strings - initial_strings) / amount.to_f)
    print " Strings  "
    print "%6.1f" % ((symbols - initial_symbols) / amount.to_f)
    print " Symbols  "
    print "GC extra: "
    print "%2d" % (runs.call - last_gc)
    puts

    data.clear

  end

end