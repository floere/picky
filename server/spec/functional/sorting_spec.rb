require 'spec_helper'

require 'ostruct'

describe 'special sorting' do
  before(:each) do
    Picky::Indexes.clear_indexes
  end

  it 'returns exact results first' do
    data = Picky::Index.new :sorted do
      key_format :to_i

      category :the_first, partial: Picky::Partial::Substring.new(from: 1)
      category :the_last, partial: Picky::Partial::Substring.new(from: 1)
    end

    SortedThing = Struct.new :id, :the_first, :the_last

    things = []
    things << SortedThing.new(1, 'Abracadabra', 'Mirgel')
    things << SortedThing.new(2, 'Abraham',     'Minder')
    things << SortedThing.new(3, 'Azzie',       'Mueller')

    sorted_by_the_first = things.sort_by(&:the_first)
    sorted_by_the_last  = things.sort_by(&:the_last)

    # We give each index a differently sorted source.
    #
    data[:the_first].source = sorted_by_the_first
    data[:the_last].source  = sorted_by_the_last

    data.index

    try = Picky::Search.new data

    # The category in which more results
    # are found determines the sort order.
    #

    # If there is the same number of results,
    # the category of the last word determines
    # the order.
    #
    try.search('a').ids.should
    try.search('m').ids.should
    try.search('a* m').ids.should
    try.search('m* a').ids.should

    # If one category has more "results",
    # it is chosen for ordering.
    #
    try.search('m* ab').ids.should
    try.search('ab* m').ids.should
    try.search('mi* a').ids.should
    try.search('a* mi').ids.should == [1, 2]
  end
end
