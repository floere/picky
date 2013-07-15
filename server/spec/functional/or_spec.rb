# encoding: utf-8
#
require 'spec_helper'

describe "OR token" do

  it 'can be given a lambda' do
    index = Picky::Index.new :or do
      category :text
    end

    require 'ostruct'

    thing = OpenStruct.new id: 1, text: "hello ohai"
    other = OpenStruct.new id: 2, text: "hello ohai kthxbye"

    index.add thing
    index.add other

    try = Picky::Search.new index
    
    # With or, or |.
    #
    try.search("hello text:ohai|text:kthxbye").ids.should == [1, 2]
    try.search("hello ohai|kthxbye").ids.should == [1, 2]
    
    # Without or, as expected.
    #
    try.search("hello text:ohai text:kthxbye").ids.should == [2]
  end

end