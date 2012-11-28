size = 75_000 # 10_000

require 'ostruct'
abc = ('0'..'9').to_a + ('a'..'f').to_a + [' ', ' ']
calculated = nil
data = lambda do
  calculated ||= (1..size).map do |i|
    OpenStruct.new(
      id: i,
      text: (30.times.inject('') do |result, _|
        result << abc[rand(abc.size)-1]
      end)
    )
  end
end

Picky::Index.new :memory do
  backend Picky::Backends::Memory.new
  source &data
  category :text,
           similarity: Picky::Similarity::DoubleMetaphone.new(3),
           partial: Picky::Partial::Substring.new(from: 2)
end
Picky::Index.new :file do
  backend Picky::Backends::File.new
  source &data
  category :text,
           similarity: Picky::Similarity::DoubleMetaphone.new(3),
           partial: Picky::Partial::Substring.new(from: 2)
end