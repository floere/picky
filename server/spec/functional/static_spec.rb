# encoding: utf-8
#
require 'spec_helper'
require 'ostruct'

describe "static option" do

  it 'does not use the realtime index' do
    thing = OpenStruct.new id: 1, text: "ohai"
    other = OpenStruct.new id: 2, text: "ohai kthxbye"
    
    static_index = Picky::Index.new :static do
      static
      
      key_format :to_i
      source { [thing, other] } # Only really makes sense with a source.
      category :text
    end
    static_index.index
    
    static_index[:text].exact.realtime.should == {}

    try = Picky::Search.new static_index
    try.search("text:ohai").ids.should == [1, 2]
  end
  
  it 'still adds to the realtime index' do
    index = Picky::Index.new :static do
      static
      
      key_format :to_i
      category :text
    end
    index.add OpenStruct.new id: 1, text: "ohai"
    index.add OpenStruct.new id: 2, text: "ohai kthxbye"
                     
    index[:text].exact.realtime.should == { 1 => ["ohai"], 2 => ["ohai", "kthxbye"] }

    try = Picky::Search.new index
    try.search("text:ohai").ids.should == [2, 1]
  end

end