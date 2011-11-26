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
  ["immediate Redis", Backends::Redis.new(immediate: true), 100],
  ["immediate SQLite", Backends::SQLite.new(self_indexed: true), 100],
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

definitions << [Proc.new do
  category :text1, weights: constant_weight, partial: no_partial
  category :text2, weights: constant_weight, partial: no_partial
  category :text3, weights: constant_weight, partial: no_partial
  category :text4, weights: constant_weight, partial: no_partial
end, :no_weights_no_partial_default_similarity]

definitions << [Proc.new do
  category :text1, weights: constant_weight
  category :text2, weights: constant_weight
  category :text3, weights: constant_weight
  category :text4, weights: constant_weight
end, :no_weights_default_partial_default_similarity]

definitions << [Proc.new do
  category :text1
  category :text2
  category :text3
  category :text4
end, :default_weights_default_partial_default_similarity]

definitions << [Proc.new do
  category :text1, partial: full_partial
  category :text2, partial: full_partial
  category :text3, partial: full_partial
  category :text4, partial: full_partial
end, :default_weights_full_partial_no_similarity]

definitions << [Proc.new do
  category :text1, similarity: double_meta
  category :text2, similarity: double_meta
  category :text3, similarity: double_meta
  category :text4, similarity: double_meta
end, :default_weights_default_partial_double_metaphone_similarity]

definitions << [Proc.new do
  category :text1, partial: full_partial, similarity: double_meta
  category :text2, partial: full_partial, similarity: double_meta
  category :text3, partial: full_partial, similarity: double_meta
  category :text4, partial: full_partial, similarity: double_meta
end, :default_weights_full_partial_double_metaphone_similarity]

puts
puts "All measurements in processed per second!"

source = Source.new 500
source.prepare

backends.each do |backend_description, backend, amount|

  puts
  puts
  print "Running tests with #{backend_description} with #{"%5d" % amount} indexed:"
  puts  "           add/index |    dump |   total"

  definitions.each do |definition, description|

    print "%65s" % description
    print ": "

    Indexes.clear_indexes
    data = Index.new :m, &definition
    data.source []
    data.backend backend

    add_duration = performance_of do
      source.each(amount) do |thing|
        data.add thing # direct
      end
    end
    dump_duration = performance_of do
      data.dump
    end

    print "%7.0f" % (amount / add_duration)
    print " | "
    print "%7.0f" % (amount / dump_duration)
    print " | "
    print "%7.0f" % (amount / (add_duration + dump_duration))
    puts

    data.clear

  end

end