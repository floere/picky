require 'spec_helper'

describe Cacher::Strategy do
  
  describe "saved?" do
    it "returns the right answer" do
      Cacher::Strategy.new.saved?.should == true
    end
  end
  
end