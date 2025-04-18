# encoding: utf-8
#
require 'spec_helper'

describe "Memory Usage" do
  
  before(:each) do
    Picky::Indexes.clear_indexes
  end
  
  let(:thing) { Struct.new(:id, :text) }
  
  # it 'is fine in String mode' do
  #   index = Picky::Index.new :memory_usage do
  #     category :text
  #   end
  #
  #   require 'objspace'
  #
  #   GC.start
  #   memsize_without_added_thing = ObjectSpace.memsize_of_all(String)
  #   GC.start
  #
  #   index.add thing.new(1, 'one')
  #
  #   GC.start
  #   memsize_with_added_thing = ObjectSpace.memsize_of_all(String)
  #   GC.start
  #
  #   index.add thing.new(1, 'one')
  #
  #   GC.start
  #   memsize_with_readded_thing = ObjectSpace.memsize_of_all(String)
  #   GC.start
  #
  #   memsize_with_readded_thing.should == memsize_with_added_thing
  # end
  
  it 'is fine with Symbols' do
    index = Picky::Index.new :memory_usage do
      symbol_keys true
      
      category :text
    end
    
    require 'objspace'
    
    GC.start
    ObjectSpace.memsize_of_all(Symbol)
    GC.start
    
    index.add thing.new(1, 'one')
    
    GC.start
    memsize_with_added_thing = ObjectSpace.memsize_of_all(Symbol)
    GC.start
    
    index.add thing.new(1, 'one')
    
    GC.start
    memsize_with_readded_thing = ObjectSpace.memsize_of_all(Symbol)
    GC.start
    
    memsize_with_readded_thing.should == memsize_with_added_thing
  end

end
