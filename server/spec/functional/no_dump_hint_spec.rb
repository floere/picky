# encoding: utf-8
#
require 'spec_helper'
require 'ostruct'

describe "Hint: no_dump" do

  let(:index) do
    Picky::Index.new :no_dump do
      optimize :no_dump
    end
  end
  let(:try) { Picky::Search.new index }

  it 'can index and search' do
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
  
  it 'fails when taking a dump' do
    index.category :text1

    thing = OpenStruct.new id: ['id1', 'thing1'], text1: "ohai"
    other = OpenStruct.new id: ['id2', 'thing2'], text1: "ohai kthxbye"

    index.add thing
    index.add other
    
    index.dump
  end

end