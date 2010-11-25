require 'spec_helper'

describe Calculations::Location do
  
  context 'without margin' do
    before(:each) do
      @calculation = Calculations::Location.new 3, 1
      @calculation.minimum = 5
    end
    describe 'reposition' do
      it 'calculates correctly' do
        @calculation.recalculate(13).should == 5
      end
      it 'calculates correctly' do
        @calculation.recalculate(5).should == 1
      end
    end
  end
  
  context 'without margin' do
    before(:each) do
      @calculation = Calculations::Location.new 3, 3
      @calculation.minimum = 5
    end
    describe 'reposition' do
      it 'calculates correctly' do
        @calculation.recalculate(13).should == 12
      end
      it 'calculates correctly' do
        @calculation.recalculate(5).should == 3
      end
    end
  end
  
end