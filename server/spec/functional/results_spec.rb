require 'spec_helper'
require 'ostruct'

describe 'Results' do
  let(:index1) { Picky::Index.new :results1 }
  let(:index2) { Picky::Index.new :results2 }
  let(:try) { Picky::Search.new index1, index2 }

  # Test the enumerator abilities.
  #
  it 'can enumerate through the allocations' do
    index1.category :text
    index2.category :text

    thing = OpenStruct.new id: 1, text: 'ohai'
    other = OpenStruct.new id: 2, text: 'ohai kthxbye'

    index1.add thing
    index1.add other
    index2.add thing

    # each
    #
    expected = [
      [2, 1],
      [1]
    ]
    try.search('text:ohai').each do |allocation|
      expected.shift.should == allocation.ids
    end

    # map
    #
    try.search('text:ohai').map(&:ids).should
    try.search('text:ohai').map(&:score).should == [0.693, 0.0]
  end

  it 'can re-prepare with different parameters' do
    index1.category :text
    index2.category :text

    thing = OpenStruct.new id: 1, text: 'ohai'
    other = OpenStruct.new id: 2, text: 'ohai kthxbye'

    index1.add thing
    index1.add other
    index2.add thing

    results = try.search 'text:ohai'
    results.ids.should

    results.prepare! nil, true
    results.ids.should
    results.ids.object_id.should_not == results.ids.object_id # Not cached.
  end
end
