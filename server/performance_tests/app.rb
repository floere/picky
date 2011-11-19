# encoding: utf-8
#

require 'sinatra/base'
require File.expand_path '../../lib/picky', __FILE__

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

  Thing = Struct.new :id, :text

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

    characters = ['a', 'b'] # ('a'..'c').to_a
    size = characters.size
    current = []

    (amount/10).times do |i|
      # 10 words per id.
      #
      10.times do
        current.clear
        length[].times do
          current << characters[rand(size)]
        end
        @buffer << Thing.new(i, current.join)
      end
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

  def initialize complexity, amount = 1_000, queries
    @complexity, @amount, @queries = complexity, amount, []
  end

  def prepare generator
    generator = generator.cycle
    amount.times do
      query = []
      complexity.times do
        query << generator.next.text
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
# extend Picky::Sinatra

# indexing substitutes_characters_with: Picky::CharacterSubstituters::WestEuropean.new,
#          removes_characters:          /[^äöüa-zA-Z0-9\s\/\-\_\:\"\&\|]/i,
#          stopwords:                   /\b(and|the|or|on|of|in|is|to|from|as|at|an)\b/i,
#          splits_text_on:              /[\s\/\-\_\:\"\&\/]/,
#          normalizes_words:            [[/\$(\w+)/i, '\1 dollars']],
#          rejects_token_if:            lambda { |token| token.blank? || token == 'Amistad' },
#          case_sensitive:              false
#
# searching substitutes_characters_with: Picky::CharacterSubstituters::WestEuropean.new,
#           removes_characters:          /[^ïôåñëäöüa-zA-Z0-9\s\/\-\_\,\&\.\"\~\*\:]/i,
#           stopwords:                   /\b(and|the|or|on|of|in|is|to|from|as|at|an)\b/i,
#           splits_text_on:              /[\s\/\&\/]/,
#           case_sensitive:              true,
#           maximum_tokens:              5

backends = [
  Backends::File.new,
  Backends::Redis.new,
  Backends::Memory.new,
]

definition = Proc.new do
  category :text
end

generate = ->(amount) do
  IndexGenerator.new(amount)
end
queries  = ->(complexity, amount = 1_000) do
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
xl  = Index.new :xl,  &definition
xl.source  { generate[1_000_000] }

puts "Running tests"

Indexes.each do |data|

  data.source.prepare
  data.prepare

  backends.each do |backend|

    data.backend backend
    data.cache

    [queries[1], queries[2], queries[3]].each do |queries|

      run = Search.new data

      queries.prepare data.source

      duration = performance_of do

        queries.each do |query|
          run.search query
        end

      end

      puts "#{duration} (#{backend}, #{data.source}, #{queries})"

    end

    # data.clear

  end

end