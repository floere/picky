# encoding: utf-8
require 'spec_helper'

describe Picky::Generator do
  
  before(:each) do
    @generator = Picky::Generator.new
  end
  
  describe "run" do
    it "should exist" do
      lambda { @generator.run(['some_arg', 'some_other_arg']) }.should_not raise_error
    end
    it "should " do
      
    end
  end
  
end