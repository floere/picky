require 'spec_helper'

describe Cacher::Partial::None do
  
  it "has the right superclass" do
    Cacher::Partial::None.should < Cacher::Partial::Strategy
  end
  it "returns an empty index" do
    Cacher::Partial::None.new.generate_from(:unimportant).should == {}
  end
  describe 'use_exact_for_partial?' do
    it 'returns true' do
      Cacher::Partial::None.new.use_exact_for_partial?.should == true
    end
  end
  
end