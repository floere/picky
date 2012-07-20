require 'spec_helper'

describe Picky::Generators::Weights::Logarithmic do

  describe 'with defaults' do
    let(:logarithmic) { described_class.new }

    describe 'saved?' do
      it 'is correct' do
        logarithmic.saved?.should == true
      end
    end

    describe 'weight_for' do
      it 'is 0 for 0' do
        logarithmic.weight_for(0).should == 0
      end
      it 'is 0 for 1' do
        logarithmic.weight_for(1).should == 0
      end
      it 'is log(x) for x' do
        logarithmic.weight_for(1234).should == Math.log(1234).round(3)
      end
    end
  end
  
  describe 'with constant' do
    let(:logarithmic) { described_class.new(3.5) }

    describe 'saved?' do
      it 'is correct' do
        logarithmic.saved?.should == true
      end
    end

    describe 'weight_for' do
      it 'is 0 for 0' do
        logarithmic.weight_for(0).should == 3.5
      end
      it 'is 0 for 1' do
        logarithmic.weight_for(1).should == 3.5
      end
      it 'is log(x) for x' do
        logarithmic.weight_for(1234).should == Math.log(1234).round(3) + 3.5
      end
    end
  end

end