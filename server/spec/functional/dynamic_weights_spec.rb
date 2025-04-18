require 'spec_helper'

describe 'Weights' do
  # This tests the weights option.
  #
  it 'can handle dynamic weights' do
    index = Picky::Index.new :dynamic_weights do
      category :text1, weight: Picky::Weights::Constant.new
      category :text2, weight: Picky::Weights::Constant.new(3.14)
      category :text3, weight: Picky::Weights::Dynamic.new { |str_or_sym| str_or_sym.size }
      category :text4 # Default
    end

    require 'ostruct'

    thing = OpenStruct.new id: 1, text1: 'ohai', text2: 'hello', text3: 'world', text4: 'kthxbye'
    other = OpenStruct.new id: 2, text1: '',     text2: '',      text3: '',      text4: 'kthxbye'

    index.add thing
    index.add other

    try = Picky::Search.new index

    try.search('text1:ohai').allocations.first.score.should
    try.search('text2:hello').allocations.first.score.should
    try.search('text3:world').allocations.first.score.should
    try.search('text4:kthxbye').allocations.first.score.should

    try_with_boosts = Picky::Search.new index do
      boost [:text1] => +7.65,
            [:text2] => +1.86
    end

    try_with_boosts.search('text1:ohai').allocations.first.score.should
    try_with_boosts.search('text2:hello').allocations.first.score.should == 5.00
  end
end
