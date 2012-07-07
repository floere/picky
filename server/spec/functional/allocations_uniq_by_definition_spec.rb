# encoding: utf-8
#
require 'spec_helper'

# This spec exists to prove that it is unnecessary
# to call allocations.uniq! when putting together results.
#
describe 'uniqueness of allocations' do

  it 'is already uniq' do
    index = Picky::Index.new :already_uniq do
      category :category1
      category :category2
      category :category3
    end

    thing = Struct.new(:id, :category1, :category2, :category3)
    index.add thing.new(1, 'text1', 'text2', 'text3')
    
    try = Picky::Search.new index do
      max_allocations 100
    end
    
    # Picky finds three categories.
    #
    try.search('text*').ids.should == [1,1,1]
    
    # Picky finds 9 possible allocations.
    #
    try.search('text* text*').ids.should == [1,1,1]*3
    
    # Picky finds 27 possible allocations.
    #
    try.search('text* text* text*', 100).ids.should == [1,1,1]*3*3
  end
end
