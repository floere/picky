# encoding: utf-8
#
require 'spec_helper'

describe 'Category#tokenize(false)' do
  
  it 'does tokenize' do
    index = Picky::Index.new :thing do
      category :text, tokenize: true
    end

    thing = Struct.new :id, :text
    index.add thing.new(1, ['already', 'tokenized']) # Does not fail – because #to_s is called on the Array.
    index.add thing.new(2, 'this should not fail')
    
    try = Picky::Search.new index
    try.search('already').ids.should == [] # Not found because ["already", is indexed.
    try.search('should').ids.should == [2]
  end
  it 'does tokenize (default)' do
    index = Picky::Index.new :thing do
      category :text
    end

    thing = Struct.new :id, :text
    # expect do # Does not fail – because #to_s is called on the Array.
    index.add thing.new(1, ['already', 'tokenized'])
    # end.to raise_error
    index.add thing.new(2, 'this should not fail')
    
    try = Picky::Search.new index
    
    try.search('already').ids.should == [] # Not found because ['already', is indexed.
  end
  it 'does not tokenize' do
    index = Picky::Index.new :thing do
      category :text, tokenize: false
    end

    thing = Struct.new :id, :text
    index.add thing.new(1, ['already', 'tokenized'])
    expect do
      index.add thing.new(2, 'this should fail')
    end.to raise_error('You probably set tokenize: false on category "text". It will need an Enumerator of previously tokenized tokens.')
    
    try = Picky::Search.new index
    
    try.search('already').ids.should == [1]
  end
  
end