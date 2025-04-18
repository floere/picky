# encoding: utf-8

require 'spec_helper'

describe 'unique option on a search' do
  it 'works' do
    index = Picky::Index.new :non_unique do
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

    things = Picky::Search.new index
    things.search('hello', 100,
                  0).ids.should == [6, 5, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1]
    things.search('hello', 100, 1).ids.should == [5, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1, 6, 5, 4, 3, 2, 1]
    # etc.

    things.search('hello', 100, 0, unique: true).ids.should == [6, 5, 4, 3, 2, 1]
    things.search('hello', 100, 1, unique: true).ids.should == [5, 4, 3, 2, 1]
    things.search('hello', 100, 2, unique: true).ids.should == [4, 3, 2, 1]
    things.search('hello', 100, 3, unique: true).ids.should == [3, 2, 1]
    things.search('hello', 100, 4, unique: true).ids.should == [2, 1]
    things.search('hello', 100, 5, unique: true).ids.should == [1]
    things.search('hello', 100, 6, unique: true).ids.should == []
  end

  it 'works' do
    index = Picky::Index.new :non_unique do
      category :text1
      category :text2
    end

    thing = Struct.new :id, :text1, :text2
    index.add thing.new(1, 'one', 'two one')
    index.add thing.new(2, 'two', 'three')
    index.add thing.new(3, 'three', 'one')

    Picky::Search.new index
    # things.search('one', 20, 0).ids.should == [3,1,1]
    # things.search('one', 20, 0).allocations.to_s.should == '[[:non_unique, 0.693, 2, [[:text2, "one", "one"]], [3, 1]], [:non_unique, 0.0, 1, [[:text1, "one", "one"]], [1]]]'
    #
    # things.search('one', 20, 0, unique: true).ids.should == [3,1]
    # things.search('one', 20, 0, unique: true).allocations.to_s.should == '[[:non_unique, 0.693, 2, [[:text2, "one", "one"]], [3, 1]]]'
  end
end
