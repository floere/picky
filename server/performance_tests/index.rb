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
  # Backends::Redis.new(immediate: true),
  Backends::Memory.new,
  Backends::File.new,
  Backends::SQLite.new,
  Backends::SQLite.new(self_indexed: true),
  Backends::Redis.new,
  Backends::Redis.new(immediate: true),
]

definitions = []

definitions << [Proc.new do
  category :text1, weights: Picky::Weights::Constant.new, partial: Picky::Partial::None.new
  category :text2, weights: Picky::Weights::Constant.new, partial: Picky::Partial::None.new
  category :text3, weights: Picky::Weights::Constant.new, partial: Picky::Partial::None.new
  category :text4, weights: Picky::Weights::Constant.new, partial: Picky::Partial::None.new
end, :no_weights_no_partial]

definitions << [Proc.new do
  category :text1, weights: Picky::Weights::Constant.new
  category :text2, weights: Picky::Weights::Constant.new
  category :text3, weights: Picky::Weights::Constant.new
  category :text4, weights: Picky::Weights::Constant.new
end, :no_weights]

definitions << [Proc.new do
  category :text1
  category :text2
  category :text3
  category :text4
end, :default]

definitions << [Proc.new do
  category :text1, partial: Picky::Partial::Postfix.new(from: 1)
  category :text2, partial: Picky::Partial::Postfix.new(from: 1)
  category :text3, partial: Picky::Partial::Postfix.new(from: 1)
  category :text4, partial: Picky::Partial::Postfix.new(from: 1)
end, :full_partial]

definitions << [Proc.new do
  category :text1, similarity: Picky::Similarity::DoubleMetaphone.new(3)
  category :text2, similarity: Picky::Similarity::DoubleMetaphone.new(3)
  category :text3, similarity: Picky::Similarity::DoubleMetaphone.new(3)
  category :text4, similarity: Picky::Similarity::DoubleMetaphone.new(3)
end, :double_metaphone]

puts
puts "All measurements in indexed per second!"

definitions.each do |definition, description|

  data = Index.new :m, &definition
  data.source { with[100] }

  puts
  puts
  puts "Running tests with definition #{description}."

  backends.each do |backend|

    data.source.prepare

    data.prepare if backend == backends.first
    data.backend backend

    print "%25s" % backend.class.name
    print ": "

    duration = performance_of do
      data.cache
    end

    print "%6.0f" % (data.source.amount/duration)
    puts

  end

end