# encoding: utf-8
#
require 'spec_helper'

describe "From option" do

  it 'can be given a lambda' do
    index = Picky::Index.new :lambda do
      category :text, from: ->(thing){ thing.some_text * 2 } # Anything, really.
    end

    require 'ostruct'

    thing = OpenStruct.new id: 1, some_text: "ohai"
    other = OpenStruct.new id: 2, some_text: "ohai kthxbye"

    index.add thing
    index.add other

    try = Picky::Search.new index

    try.search("text:ohaiohai").ids.should == [1]
  end

end