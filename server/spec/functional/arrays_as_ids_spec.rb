# encoding: utf-8
#
require 'spec_helper'

describe "Array IDs" do

  # This tests the weights option.
  #
  it 'can use Arrays as IDs' do
    index = Picky::Index.new :arrays do
      category :text1
    end

    require 'ostruct'

    thing = OpenStruct.new id: ['id1', 'thing1'], text1: "ohai"
    other = OpenStruct.new id: ['id2', 'thing2'], text1: "ohai kthxbye"

    index.add thing
    index.add other

    try = Picky::Search.new index

    try.search("text1:ohai").ids.should == [
      ["id2", "thing2"],
      ["id1", "thing1"]
    ]
  end

  # This tests the weights option.
  #
  it 'can use split as key_format' do
    index = Picky::Index.new :arrays do
      key_format :split
      
      category :text1
    end

    require 'ostruct'
    
    thing = OpenStruct.new id: "id1 thing1", text1: "ohai"
    other = OpenStruct.new id: "id2 thing2", text1: "ohai kthxbye"

    index.add thing
    index.add other

    try = Picky::Search.new index

    try.search("text1:ohai").ids.should == [
      ["id2", "thing2"],
      ["id1", "thing1"]
    ]
  end

end