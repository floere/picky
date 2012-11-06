# encoding: utf-8
#
require 'spec_helper'

describe 'range queries' do
  
  let(:index) do
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
    
    index
  end
  let(:try) { Picky::Search.new index }

  it 'still works with exact queries' do
    try.search('1980').ids.should == []
    try.search('1989').ids.should == [3]
  end
    
  it 'handles basic range queries' do
    try.search('1980-2001').ids.should == [8,3,1]
    try.search('f-u').ids.should == [2,1,8,7,4]
  end
  
  it 'can handle qualifiers' do
    try.search('year:1980-2001').ids.should == [8,3,1]
    try.search('alphabet:f-u').ids.should == [2,1,8,7,4]
  end
  
  it 'can be combined with other search words' do
    try.search('1980-2001 a').ids.should == [3]
    try.search('f-u 881').ids.should == [7]
  end
  
  it 'can handle multiple range queries' do
    try.search('1980-2001 a-h').ids.should == [3,1]
    try.search('f-u 881-1977').ids.should == [2,7]
  end
  
  it 'can be combined with partial queries' do
    try.search('198* a-h').ids.should == [3]
  end
  
  it 'works with nonsensical ranges' do
    try.search('h-a').ids.should == []
  end
  
  # it 'handles combined range/partial queries' do
  #   # TODO This still needs to be refined. It is madness.
  #   #
  #   try.search('198-200*').ids.should == [8,3,1,4,5,7,6,2]
  # end
  
end