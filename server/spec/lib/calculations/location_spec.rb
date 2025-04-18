require 'spec_helper'

describe Picky::Calculations::Location do
  context 'with precision 1' do
    before(:each) do
      @calculation = described_class.new 1.5, 42.7, 1
    end
    describe 'calculated_range' do
      it 'returns the right range' do
        @calculation.calculated_range(40.0).should == (-2..0)
      end
      it 'returns the right range' do
        @calculation.calculated_range(41.0).should == (-1..1)
      end
      it 'returns the right range' do
        @calculation.calculated_range(0).should == (-42..-40)
      end
    end
    describe 'calculate' do
      it 'sets the anchor close value to the minimum minus user grid' do
        @calculation.calculate(41.2).should == 1
      end
      it 'sets the anchor value to 1 plus precision' do
        @calculation.calculate(42.7).should == 2
      end
      it 'sets the anchor value plus 2/3 of the grid size to 2 plus 1 grid length' do
        @calculation.calculate(43.7).should == 3
      end
      it 'sets the anchor value plus 20/3 of the grid size to 2 plus 10 grid length' do
        @calculation.calculate(52.7).should == 12
      end
    end
  end

  context 'with precision 3' do
    before(:each) do
      @calculation = described_class.new 1.5, 42.7, 3
    end
    describe 'calculate' do
      it 'sets the anchor close value to the minimum minus user grid' do
        @calculation.calculate(41.2).should == 1
      end
      it 'sets the anchor value to 1 plus precision' do
        @calculation.calculate(42.7).should == 4
      end
      it 'sets the anchor value plus 2/3 of the grid size plus 1 plus precision plus 1 grid length' do
        @calculation.calculate(43.7).should == 6
      end
      it 'sets the anchor value plus 20/3 of the grid size to 2 plus 10 grid length' do
        @calculation.calculate(52.7).should == 27
      end
    end
  end
end
