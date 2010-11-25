require 'spec_helper'

describe Calculations::Location do
  
  before(:each) do
    @calculation = Calculations::Location.new 1, 3
  end
  
  context 'without margin' do
    describe 'reposition' do
      it 'calculates correctly' do
        @calculation.reposition(13).should == 4
      end
      it 'calculates correctly' do
        @calculation.reposition(1).should == 0
      end
    end
  end
  context 'with margin' do
    before(:each) do
      @calculation.add_margin 5
    end
    describe 'reposition' do
      it 'calculates correctly' do
        @calculation.reposition(13).should == 5
      end
    end
  end
  
end