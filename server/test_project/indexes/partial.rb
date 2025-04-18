PartialItem = Struct.new :id, :substring, :postfix, :infix, :none
PartialIndex = Picky::Index.new(:partial) do
  key_format :to_i
  source do
    [
      PartialItem.new(1, 'octopussy', 'octopussy', 'octopussy', 'octopussy'),
      PartialItem.new(2, 'abracadabra', 'abracadabra', 'abracadabra', 'abracadabra')
    ]
  end
  category :substring, partial: Picky::Partial::Substring.new(from: -5, to: -3)
  category :postfix, partial: Picky::Partial::Postfix.new(from: -5)
  category :infix, partial: Picky::Partial::Infix.new
  category :none, partial: Picky::Partial::None.new
end
