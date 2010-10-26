require 'spec_helper'

describe Cacher::Partial::Default do
  
  it "should be a subtoken" do
    Cacher::Partial::Default.should be_kind_of(Cacher::Partial::Substring)
  end
  it "should be a the right down to" do
    Cacher::Partial::Default.from.should == -3
  end
  it "should be a the right starting at" do
    Cacher::Partial::Default.to.should == -1
  end
  
end