require 'spec_helper'

describe Cacher::Partial::Default do
  
  it "should be a subtoken" do
    Cacher::Partial::Default.should be_kind_of(Cacher::Partial::Subtoken)
  end
  it "should be a the right down to" do
    Cacher::Partial::Default.down_to.should == 1
  end
  it "should be a the right starting at" do
    Cacher::Partial::Default.starting_at.should == 0
  end
  
end