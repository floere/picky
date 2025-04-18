# encoding: utf-8

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
    try.search('hello world').ids.should == [1, 1, 1, 1]

    try_again = Picky::Search.new index do
      max_allocations 2
    end

    try_again.search('hello world').allocations.size.should == 2
    try_again.search('hello world').ids.should == [1, 1]

    try_again.max_allocations 1

    try_again.search('hello world').allocations.size.should == 1
    try_again.search('hello world').ids.should == [1]
  end

  it 'gets faster' do
    index = Picky::Index.new :dynamic_weights do
      category :text1
      category :text2
      category :text3
      category :text4
    end

    thing = Struct.new :id, :text1, :text2, :text3, :text4
    index.add thing.new(1, 'hello world', 'hello world', 'hello world', 'hello world')
    index.add thing.new(2, 'hello world', 'hello world', 'hello world', 'hello world')
    index.add thing.new(3, 'hello world', 'hello world', 'hello world', 'hello world')
    index.add thing.new(4, 'hello world', 'hello world', 'hello world', 'hello world')
    index.add thing.new(5, 'hello world', 'hello world', 'hello world', 'hello world')
    index.add thing.new(6, 'hello world', 'hello world', 'hello world', 'hello world')

    try = Picky::Search.new index

    threshold = performance_of do
      try.search 'hello world'
    end

    try_again = Picky::Search.new index do
      max_allocations 1
    end

    performance_of do
      try_again.search 'hello world'
    end.should < threshold
  end
end
