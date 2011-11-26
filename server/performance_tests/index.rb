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

  def each &block
    @buffer.each &block
  end

end

with = ->(amount) do
  Source.new amount
end

include Picky

backends = [
  ["immediate Redis", Backends::Redis.new(immediate: true)],
  ["immediate SQLite", Backends::SQLite.new(self_indexed: true)],
  ["standard Redis", Backends::Redis.new],
  ["standard SQLite", Backends::SQLite.new],
  ["standard File", Backends::File.new],
  ["standard Memory", Backends::Memory.new],
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
puts "All measurements in indexed per second!"

backends.each do |backend_description, backend|

  puts
  puts
  puts "Running tests with #{backend_description}:"

  definitions.each do |definition, description|

    data = Index.new :m, &definition
    data.source { with[200] }
    data.source.prepare

    data.prepare if backend == backends.first
    data.backend backend

    print "%65s" % description
    print ": "

    duration = performance_of do
      data.cache
    end

    print "%6.0f" % (data.source.amount/duration)
    puts

    data.clear

  end

end