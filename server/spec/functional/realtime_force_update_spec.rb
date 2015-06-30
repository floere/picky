# encoding: utf-8
#
require 'spec_helper'

# Shows that realime update data can be ignored if they are
# already in the index.
#
describe 'ignoring updates' do
  
  normal_index = Picky::Index.new :normal do
    category :title
  end
  
  symbol_keys_index = Picky::Index.new :symbol do
    symbol_keys
    
    category :title
  end
  
  static_index = Picky::Index.new :static do
    static
    
    category :title
  end
  
  [normal_index, symbol_keys_index, static_index].each do |index|
    it 'does not update the index if the added data stayed the same' do
      thing = Struct.new :id, :title
      index.add thing.new(1, 'some title')
      index.add thing.new(2, 'some title')
    
      try = Picky::Search.new index
    
      try.search('some').ids.should == [2, 1]
    
      index.add thing.new(1, 'some title'), force_update: true
    
      # Expected behavior.
      try.search('some').ids.should == [1, 2]
    
      index.add thing.new(2, 'some title') # force_update: false is the default.
    
      # Not updated, since it was the exact same data everywhere.
      try.search('some').ids.should == [1, 2]
    
      index.add thing.new(2, 'some title'), force_update: false
    
      # Not updated, since it was the exact same data everywhere.
      try.search('some').ids.should == [1, 2]
    end
  
    it 'does always update the index if replace is used' do
      index = Picky::Index.new :books do
        category :title
      end

      thing = Struct.new :id, :title
      index.add thing.new(1, 'some title')
      index.add thing.new(2, 'some title')
    
      try = Picky::Search.new index
    
      try.search('some').ids.should == [2, 1]
    
      index.replace thing.new(1, 'some title')
    
      # Expected behavior.
      try.search('some').ids.should == [1, 2]
    end
  end
end
