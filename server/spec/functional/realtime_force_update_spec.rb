# encoding: utf-8
#
require 'spec_helper'

# Shows that realime update data can be ignored if they are
# already in the index.
#
describe 'ignoring updates' do

  it 'does not update the index if the updated data stayed the same' do
    index = Picky::Index.new :books do
      category :title
    end

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
end
