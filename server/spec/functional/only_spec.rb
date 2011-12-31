# encoding: utf-8
#
require 'spec_helper'

describe 'Search#only' do

  it 'offers the option only' do
    index = Picky::Index.new :only do
      category :category1
      category :category2
      category :category3
    end

    index.add Struct.new(:id, :category1, :category2, :category3).new(1, 'text1', 'text2', 'text3')

    try = Picky::Search.new index
    try.search('text1').ids.should == [1]
    try.search('text2').ids.should == [1]
    try.search('text3').ids.should == [1]

    try_again = Picky::Search.new index do
      only :category1
    end
    try_again.search('text1').ids.should == [1]
    try_again.search('text2').ids.should == []
    try_again.search('text3').ids.should == []

    try_again.only :category2, :category3
    
    try_again.search('text1').ids.should == []
    try_again.search('text2').ids.should == [1]
    try_again.search('text3').ids.should == [1]
    
    try_again.search('category1:text1').ids.should == []
    try_again.search('category1:text2').ids.should == []
    try_again.search('category1:text3').ids.should == []
    
    try_again.search('category2:text1').ids.should == []
    try_again.search('category2:text2').ids.should == [1]
    try_again.search('category2:text3').ids.should == []
    
    try_again.search('category3:text1').ids.should == []
    try_again.search('category3:text2').ids.should == []
    try_again.search('category3:text3').ids.should == [1]
    
    try_again.search('category1,category2:text1').ids.should == []
    try_again.search('category1,category2:text2').ids.should == [1]
    try_again.search('category1,category2:text3').ids.should == []
    
    try_again.search('category1,category3:text1').ids.should == []
    try_again.search('category1,category3:text2').ids.should == []
    try_again.search('category1,category3:text3').ids.should == [1]
    
    try_again.search('category2,category3:text1').ids.should == []
    try_again.search('category2,category3:text2').ids.should == [1]
    try_again.search('category2,category3:text3').ids.should == [1]
    
    try_again.search('category1,category2,category3:text1').ids.should == []
    try_again.search('category1,category2,category3:text2').ids.should == [1]
    try_again.search('category1,category2,category3:text3').ids.should == [1]
  end
end