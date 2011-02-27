require 'spec_helper'

describe Internals::Generators::Partial::Default do
  
  let(:default) { Internals::Generators::Partial::Default }
  
  it "should be a subtoken" do
    default.should be_kind_of(Internals::Generators::Partial::Substring)
  end
  it "should be a the right down to" do
    default.from.should == -3
  end
  it "should be a the right starting at" do
    default.to.should == -1
  end
  
end