# encoding: utf-8
#
require 'spec_helper'

describe Picky::Pool do
  
  class PoolTest
    extend Picky::Pool
    
    def initialize number
      @number = number
    end
  end
  
  context 'functional' do
    it 'lets me get an instance' do
      PoolTest.obtain(1).should be_kind_of(PoolTest)
    end
    it 'does not create a new reference if it has free ones' do
      pt1 = PoolTest.obtain 1
      pt2 = PoolTest.obtain 2
      pt1.release
      
      PoolTest.pool_size.should == 1
    end
    it 'gives me the released reference if I try to obtain' do
      pt1 = PoolTest.obtain 1
      pt2 = PoolTest.obtain 2
      pt1.release
      
      PoolTest.obtain(3).should == pt1 # TODO But it should then contain 3 as a number!
    end
  end
  
end
