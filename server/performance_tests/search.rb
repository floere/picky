# encoding: utf-8
#

require 'sinatra/base'
require File.expand_path '../../lib/picky', __FILE__

class Object

  def timed_exclaim _

  end

end

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

class IndexGenerator

  attr_reader :amount, :length

  def initialize amount, &length
    @amount = amount
    @length = length || ->() { rand(6) + 3 }
  end

  Thing = Struct.new :id, :text1, :text2, :text3, :text4

  # Generation.
  #
  # This generates an amount of
  # words consisting of the characters
  # a-e. Of sizes 3-9.
  #
  # Queries for these will be generated later.
  #
  def prepare
    @buffer = []

    characters = ['a', 'b', 'c', 'd'] # ('a'..'c').to_a
    size = characters.size

    amount.times do |i|
      # 10*3 words per id.
      #
      # 10.times do
        args = []
        4.times do
          current = []
          length[].times do
            current << characters[rand(size)]
          end
          args << current.join
        end
        @buffer << Thing.new(i, *args)
      # end
    end
  end

  def each &block
    @buffer.each &block
  end

  def cycle
    @buffer.cycle
  end

  def to_s
    "#{self.class}(amount: #{amount})"
  end

end

class QueryGenerator

  attr_reader :complexity, :amount, :queries

  def initialize complexity, amount
    @complexity, @amount, @queries = complexity, amount, []
  end

  def prepare generator
    generator = generator.cycle
    amount.times do
      query = []
      complexity.times do |i|
        query << generator.next.send(:"text#{i+1}")[0..-(rand(3)+1)]
      end
      @queries << query.join(' ')
    end
  end

  def each &block
    queries.each &block
  end

  def to_s
    "#{self.class}(complexity: #{complexity}, amount: #{amount})"
  end

end

include Picky

backends = [
  Backends::Redis.new,
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

generate = ->(amount) do
  IndexGenerator.new(amount)
end
queries  = ->(complexity, amount) do
  QueryGenerator.new complexity, amount
end

xxs = Index.new :xxs, &definition
xxs.source { generate[10] }
xs  = Index.new :xs,  &definition
xs.source  { generate[100] }
s   = Index.new :s,   &definition
s.source   { generate[1_000] }
m   = Index.new :m,   &definition
m.source   { generate[10_000] }
l   = Index.new :l,   &definition
l.source   { generate[100_000] }
# xl  = Index.new :xl,  &definition
# xl.source  { generate[1_000_000] }

puts "Running tests"

backends.each do |backend|

  puts
  puts backend.class

  Indexes.each do |data|

    if backend == backends.first
      data.source.prepare
      data.prepare
    end

    data.backend backend
    data.clear
    data.cache
    data.load

    amount = 100

    print "%7d" % data.source.amount

    [queries[1, amount], queries[2, amount], queries[3, amount], queries[4, amount]].each do |queries|

      run = Search.new data

      queries.prepare data.source

      duration = performance_of do

        queries.each do |query|
          # p query
          run.search query
        end

      end

      print ", "
      print "%2.4f" % duration

    end

    puts

  end

end