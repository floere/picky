# encoding: utf-8
#
require 'spec_helper'

describe 'qualifier remapping' do

  it 'can have new qualifiers' do
    index = Picky::Index.new :qualifier_remapping do
      category :a
    end

    Thing = Struct.new(:id, :a, :b)
    
    index.add Thing.new(1, "a", "b")
    
    try = Picky::Search.new index
    
    # Picky finds nothing.
    #
    try.search('b').ids.should == []
    
    # Add a new category and a thing.
    #
    index.category :b
    index.add Thing.new(2, "c", "b")
    
    # It finds it.
    #
    try.search('b').ids.should == [2]
    
    # But not with qualifier!
    #
    try.search('b:b').ids.should == []
    
    # So remap the qualifiers.
    #
    try.remap_qualifiers
    
    # Now it works!
    #
    try.search('b:b').ids.should == [2]
  end
end
