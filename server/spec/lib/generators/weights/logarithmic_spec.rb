require 'spec_helper'

describe Picky::Generators::Weights::Logarithmic do

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
      logarithmic.weight_for(1234).should == Math.log(1234)
    end
  end

end