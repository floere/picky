# encoding: utf-8
#
require 'spec_helper'

describe 'Search#only' do

  it 'offers the option only' do
    index = Picky::Index.new :only do
      category :text1
      category :text2
      category :text3
    end

    index.add Struct.new(:id, :text1, :text2, :text3).new(1, 'text1', 'text2', 'text3')

    try = Picky::Search.new index
    try.search('text1').ids.should == [1]
    try.search('text2').ids.should == [1]
    try.search('text3').ids.should == [1]

    try_again = Picky::Search.new index do
      only :text1
    end
    try_again.search('text1').ids.should == [1]
    try_again.search('text2').ids.should == []
    try_again.search('text3').ids.should == []

    try_again.only :text2, :text3
    try_again.search('text1').ids.should == []
    try_again.search('text2').ids.should == [1]
    try_again.search('text3').ids.should == [1]
    
    try_again.search('text1:text1').ids.should == []
    try_again.search('text2:text2').ids.should == [1]
    try_again.search('text3:text3').ids.should == [1]
    
    try_again.search('text1,text2,text3:text1').ids.should == []
    try_again.search('text1,text2:text1').ids.should == []
    try_again.search('text1,text3:text1').ids.should == []
    
    try_again.search('text1,text2,text3:text2').ids.should == [1]
    try_again.search('text1,text2:text2').ids.should == [1]
    try_again.search('text1,text3:text2').ids.should == []
    
    try_again.search('text1,text2,text3:text3').ids.should == [1]
    try_again.search('text1,text2:text3').ids.should == []
    try_again.search('text1,text3:text3').ids.should == [1]
  end
end