require 'csv'
require 'sinatra/base'
require_relative '../lib/picky'
require_relative 'helpers'
require_relative 'source'

gc = ENV['GC']

# Reopen class.
#
class Source
  def prepare
    @buffer = []
    i = 0
    CSV.open('data.csv').each do |args|
      @buffer << Thing.new(*args)
      break if (i += 1) == @amount
    end
  end

  def each(up_to = nil, &block)
    @buffer[0..(up_to || amount)].each(&block)
  end
end

include Picky
Picky.logger = Picky::Loggers::Silent.new

backends = [
  # ["realtime Redis", Backends::Redis.new(realtime: true), 100],
  # ["realtime SQLite", Backends::SQLite.new(realtime: true), 100],
  # ["standard Redis", Backends::Redis.new, 200],
  # ["standard SQLite", Backends::SQLite.new, 200],
  # ["standard File", Backends::File.new, 300],
  ['standard Memory', Backends::Memory.new, 1000],
]

constant_weight = Picky::Weights::Constant.new
no_partial      = Picky::Partial::None.new
full_partial    = Picky::Partial::Postfix.new from: 1
double_meta     = Picky::Similarity::DoubleMetaphone.new 3

def definition_with(categories_amount, identifier, options = {})
  [Proc.new do
    1.upto(categories_amount).each do |i|
      category :"text#{i}", options
    end
  end, "#{identifier} (#{categories_amount})"]
end

def definitions_with(upto, identifier, options = {})
  definitions = []
  (1..upto).each do |categories_amount|
    definitions << definition_with(categories_amount, identifier, options)
  end
  definitions
end

amount = 5

definitions = []
definitions += definitions_with(amount, :no_weights_no_partial_no_similarity, weight: constant_weight,
                                                                              partial: no_partial)
definitions += definitions_with(amount, :no_weights_default_partial_no_similarity, weight: constant_weight)
definitions += definitions_with(amount, :default_weights_default_partial_no_similarity)
definitions += definitions_with(amount, :default_weights_full_partial_no_similarity, partial: full_partial)
definitions += definitions_with(amount, :default_weights_default_partial_double_metaphone_similarity,
                                similarity: double_meta)
definitions += definitions_with(amount, :default_weights_full_partial_double_metaphone_similarity,
                                partial: full_partial, similarity: double_meta)

puts
puts
puts 'All measurements in processed per second!'

source = Source.new 1000
source.prepare

GC.enable
GC::Profiler.enable

backends.each do |backend_description, backend, amount|
  puts
  print "Running tests with #{backend_description} with #{"%5d" % amount} indexed:"
  print '           add/index |    dump |   total      '
  puts gc ? 'RAM/string/symbols per indexed' : ''

  definitions.each do |definition, description|
    print '%65s' % description
    print ': '

    Indexes.clear_indexes

    data = Index.new :m, &definition
    data.backend backend

    if gc
      GC.start
      initial_ram = ram __FILE__
      initial_strings = string_count
      initial_symbols = Symbol.all_symbols.size

      last_gc = runs
    end

    add_duration = performance_of do
      source.each(amount) do |thing|
        data.add thing # direct
      end
    end

    if gc
      current_ram = ram(__FILE__) - initial_ram
      strings = string_count
      symbols = Symbol.all_symbols.size
    end

    print '%7.0f' % (amount / add_duration)
    print ' | '

    dump_duration = performance_of do
      data.dump
    end

    print '%7.0f' % (amount / dump_duration)
    print ' | '
    print '%7.0f' % (amount / (add_duration + dump_duration))
    if gc
      print '   '
      print '%5d' % (current_ram / amount)
      print 'K  '
      print '%6.1f' % ((strings - initial_strings) / amount.to_f)
      print ' Strings  '
      print '%6.1f' % ((symbols - initial_symbols) / amount.to_f)
      print ' Symbols  '
      print 'GC extra: '
      print '%2d' % (runs - last_gc)
    end
    puts

    data.clear
  end
end
