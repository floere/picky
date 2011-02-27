require 'spec_helper'

describe Cacher::Weights::Logarithmic do

  before(:each) do
    @cacher = Cacher::Weights::Logarithmic.new
  end

  describe 'generate_from' do
    it 'should not fail on empties' do
      @cacher.generate_from({ :key => [] }).should == { :key => 0 }
    end
    it 'should round to 2' do
      @cacher.generate_from({ :key => [1,2,3,4] }).should == { :key => 1.39 }
    end
  end

  describe 'weight_for' do
    it 'should be 0 for 0' do
      @cacher.weight_for(0).should == 0
    end
    it 'should be 0 for 1' do
      @cacher.weight_for(1).should == 0
    end
    it 'should be log(x) for x' do
      @cacher.weight_for(1234).should == Math.log(1234)
    end
  end

end