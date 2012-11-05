# encoding: utf-8
#
require 'spec_helper'

describe 'range queries' do

  it 'offers custom partial delimiters to be set' do
    index = Picky::Index.new :range_queries do
      category :year
      category :alphabet
    end
    
    rangy = Struct.new :id, :year, :alphabet
    
    index.add rangy.new(1, 2000, 'g')
    index.add rangy.new(2, 1977, 'f')
    index.add rangy.new(3, 1989, 'a')
    index.add rangy.new(4, 2011, 'u')
    index.add rangy.new(5, 3000, 'v')
    index.add rangy.new(6, 1291, 'z')
    index.add rangy.new(7,  881, 'm')
    index.add rangy.new(8, 1984, 'l')

    try = Picky::Search.new index
    
    # Try exact ones.
    #
    try.search('1980').ids.should == []
    try.search('1989').ids.should == [3]
    
    # Range queries.
    #
    try.search('1980-2001').ids.should == [8,3,1]
    try.search('f-u').ids.should == [2,1,8,7,4]
    
    # With qualifier.
    #
    try.search('year:1980-2001').ids.should == [8,3,1]
    try.search('alphabet:f-u').ids.should == [2,1,8,7,4]
  end
  
end