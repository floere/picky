require 'spec_helper'

describe Internals::Generators::Partial::None do
  
  it 'is not saved' do
    described_class.new.saved?.should == false
  end
  it "has the right superclass" do
    described_class.should < Internals::Generators::Partial::Strategy
  end
  it "returns an empty index" do
    described_class.new.generate_from(:unimportant).should == {}
  end
  describe 'use_exact_for_partial?' do
    it 'returns true' do
      described_class.new.use_exact_for_partial?.should == true
    end
  end
  
end