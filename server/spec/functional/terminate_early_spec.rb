# encoding: utf-8
#
require 'spec_helper'

describe 'Search#terminate_early' do

  it 'terminates early' do
    index = Picky::Index.new :terminate_early do
      category :text1
      category :text2
      category :text3
      category :text4
    end

    thing = Struct.new :id, :text1, :text2, :text3, :text4
    index.add thing.new(1, 'hello', 'hello', 'hello', 'hello')
    index.add thing.new(2, 'hello', 'hello', 'hello', 'hello')
    index.add thing.new(3, 'hello', 'hello', 'hello', 'hello')
    index.add thing.new(4, 'hello', 'hello', 'hello', 'hello')
    index.add thing.new(5, 'hello', 'hello', 'hello', 'hello')
    index.add thing.new(6, 'hello', 'hello', 'hello', 'hello')

    try = Picky::Search.new index
    try.search('hello').ids.should == [6, 5, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 6, 5]

    try = Picky::Search.new index do
      terminate_early
    end
    try.search('hello', 3).ids.should == [6, 5, 4]

    try = Picky::Search.new index do
      terminate_early
    end
    try.search('hello', 9).ids.should == [6, 5, 4, 3, 2, 1, 6, 5, 4]

    try = Picky::Search.new index do
      terminate_early with_extra_allocations: 0
    end
    try.search('hello', 9).ids.should == [6, 5, 4, 3, 2, 1, 6, 5, 4]

    try = Picky::Search.new index do
      terminate_early 0
    end
    try.search('hello').ids.should == [6, 5, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1]

    try = Picky::Search.new index do
      terminate_early with_extra_allocations: 0
    end
    try.search('hello').ids.should == [6, 5, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1]

    try = Picky::Search.new index do
      terminate_early 2
    end
    try.search('hello', 13).ids.should == [6, 5, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 6]

    try = Picky::Search.new index do
      terminate_early with_extra_allocations: 2
    end
    try.search('hello').ids.should == [6, 5, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 6, 5]

    try = Picky::Search.new index do
      terminate_early with_extra_allocations: 1234
    end
    try.search('hello').ids.should == [6, 5, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 6, 5]

    slow = performance_of do
      try.search 'hello'
    end

    try = Picky::Search.new index do
      terminate_early
    end
    fast = performance_of do
      try.search 'hello'
    end
    
    (slow/fast).should
  end

end