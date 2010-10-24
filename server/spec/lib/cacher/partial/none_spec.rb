require 'spec_helper'

describe Cacher::Partial::None do
  
  it "has the right superclass" do
    Cacher::Partial::None.should < Cacher::Partial::Strategy
  end
  it "returns an empty index" do
    Cacher::Partial::None.new.generate_from(:unimportant).should == {}
  end
  
end