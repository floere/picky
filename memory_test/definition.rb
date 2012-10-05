require 'ostruct'

abc = ('a'..'z').to_a + [' ', ' ']

Picky::Index.new :memory do
  backend Picky::Backends::Memory.new
  source do
    (1..75_000).map do |i|
      OpenStruct.new(
        id: i,
        text: (30.times.inject('') do |result, _|
          result << abc[rand(abc.size)-1]
        end)
      )
    end
  end
  category :text,
           similarity: Picky::Similarity::DoubleMetaphone.new(3),
           partial: Picky::Partial::Substring.new(from: 2)
end