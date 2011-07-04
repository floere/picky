require 'spec_helper'

describe Generators::Partial::Default do
  
  let(:default) { Generators::Partial::Default }
  
  it "should be a subtoken" do
    default.should be_kind_of(Generators::Partial::Substring)
  end
  it "should be a the right down to" do
    default.from.should == -3
  end
  it "should be a the right starting at" do
    default.to.should == -1
  end
  
end