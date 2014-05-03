# encoding: utf-8
#
require 'spec_helper'
require 'ostruct'

describe "Array IDs" do

  let(:index) { Picky::Index.new :arrays }
  let(:try) { Picky::Search.new index }

  # This tests the weights option.
  #
  it 'can use Arrays as IDs' do
    index.category :text1

    thing = OpenStruct.new id: ['id1', 'thing1'], text1: "ohai"
    other = OpenStruct.new id: ['id2', 'thing2'], text1: "ohai kthxbye"

    index.add thing
    index.add other

    try.search("text1:ohai").ids.should == [
      ["id2", "thing2"],
      ["id1", "thing1"]
    ]
  end

  # This tests the weights option.
  #
  it 'can use split as key_format' do
    index.key_format :split
    index.category :text1

    thing = OpenStruct.new id: "id1 thing1", text1: "ohai"
    other = OpenStruct.new id: "id2 thing2", text1: "ohai kthxbye"

    index.add thing
    index.add other

    try.search("text1:ohai").ids.should == [
      ["id2", "thing2"],
      ["id1", "thing1"]
    ]
  end

end