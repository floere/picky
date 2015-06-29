# encoding: utf-8
#
require 'spec_helper'

describe "Memory optimization" do
  
  before(:each) do
    # Remove all indexes.
    Picky::Indexes.clear_indexes
    
    @index = Picky::Index.new :memory_optimization do
      category :text1
      category :text2
      category :text3
      category :text4
    end
    
    @thing = Struct.new(:id, :text1, :text2, :text3, :text4)
  end
  
  attr_reader :index, :thing
  
  it 'saves memory' do
    require 'objspace'
    
    GC.start
    memsize_without_added_thing = ObjectSpace.memsize_of_all(Array)
    GC.start
    
    index.add thing.new(1, 'one', 'two', 'three', 'four')
    
    GC.start
    memsize_with_added_thing = ObjectSpace.memsize_of_all(Array)
    GC.start
    
    memsize_with_added_thing.should > memsize_without_added_thing
    
    Picky::Indexes.optimize_memory
    
    GC.start
    memsize_with_optimized_memory = ObjectSpace.memsize_of_all(Array)
    GC.start
    
    # Still larger than with nothing.
    memsize_without_added_thing.should < memsize_with_optimized_memory
    # But smaller than with added.
    memsize_with_optimized_memory.should < memsize_with_added_thing
  end

end
