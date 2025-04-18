# This just tests indexing.
#
WeightsItem = Struct.new :id, :logarithmic, :constant_default, :constant, :dynamic
Picky::Index.new(:weights) do
  key_format :to_i
  source do
    [
      WeightsItem.new(1, 'octopussy', 'octopussy', 'octopussy', 'octopussy'),
      WeightsItem.new(2, 'abracadabra', 'abracadabra', 'abracadabra', 'abracadabra')
    ]
  end
  category :logarithmic,      weight: Picky::Weights::Logarithmic.new
  category :constant_default, weight: Picky::Weights::Constant.new
  category :constant,         weight: Picky::Weights::Constant.new(3.14)
  category :dynamic,          weight: Picky::Weights::Dynamic.new { |token| token.size }
end
