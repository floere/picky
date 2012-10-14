# encoding: utf-8
#
require 'spec_helper'

require 'ostruct'

describe "special sorting" do

  before(:each) do
    Picky::Indexes.clear_indexes
  end

  it 'returns exact results first' do
    data = Picky::Index.new :sorted do
      category :first, partial: Picky::Partial::Substring.new(from: 1)
      category :last, partial: Picky::Partial::Substring.new(from: 1)
    end
    
    SortedThing = Struct.new :id, :first, :last
    
    things = []
    things << SortedThing.new(1, 'Abracadabra', 'Mirgel')
    things << SortedThing.new(2, 'Abraham',     'Minder')
    things << SortedThing.new(3, 'Azzie',       'Mueller')
    
    sorted_by_first = things.sort_by &:first
    sorted_by_last  = things.sort_by &:last
    
    # We give each index a differently sorted source.
    #
    data[:first].source = sorted_by_first
    data[:last].source  = sorted_by_last
    
    data.index
    
    try = Picky::Search.new data
    
    # The category in which more results
    # are found determines the sort order.
    #

    # If there is the same number of results,
    # the category of the last word determines
    # the order.
    #
    try.search('a').ids.should == [1,2,3]
    try.search('m').ids.should == [2,1,3]
    try.search('a* m').ids.should == [2,1,3]
    try.search('m* a').ids.should == [1,2,3]

    # If one category has more "results",
    # it is chosen for ordering.
    #
    try.search('m* ab').ids.should == [2,1]
    try.search('ab* m').ids.should == [2,1]
    try.search('mi* a').ids.should == [1,2]
    try.search('a* mi').ids.should == [1,2]
  end
  
end