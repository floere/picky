# encoding: utf-8
#
require 'spec_helper'
require 'ostruct'

describe "Option symbol_keys" do

  let(:index) do
    Picky::Index.new(:results1) { symbol_keys true }
  end
  let(:try) do
    Picky::Search.new(index) { symbol_keys }
  end

  # Test the enumerator abilities.
  #
  it 'can enumerate through the allocations' do
    index.category :text

    thing = OpenStruct.new id: 1, text: "ohai"
    other = OpenStruct.new id: 2, text: "ohai kthxbye"

    index.add thing
    index.add other

    try.search("text:ohai").ids.should == [2, 1]
  end

end