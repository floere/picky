# encoding: utf-8
#
require 'spec_helper'

describe 'Search#max_allocations' do

  it 'offers the option max_allocations' do
    index = Picky::Index.new :dynamic_weights do
      category :text1
      category :text2
    end

    index.add Struct.new(:id, :text1, :text2).new(1, 'hello world', 'hello world')

    try = Picky::Search.new index

    try.search('hello world').allocations.size.should == 4
    try.search('hello world').ids.should == [1,1,1,1]

    try_again = Picky::Search.new index do
      max_allocations 2
    end

    try_again.search('hello world').allocations.size.should == 2
    try_again.search('hello world').ids.should == [1,1]

    try_again.max_allocations 1

    try_again.search('hello world').allocations.size.should == 1
    try_again.search('hello world').ids.should == [1]
  end

end