# encoding: utf-8
require 'spec_helper'

describe Picky::Generator do
  
  describe "main class" do
    before(:each) do
      @generator = Picky::Generator.new
    end

    describe "generate" do
      it "should exist" do
        lambda { @generator.generate(['project', 'some_project']) }.should_not raise_error
      end
      it "should " do

      end
    end
  end
  
  describe Picky::Generator::Project do
    
    before(:each) do
      @generator = Picky::Generator::Project.new :some_name, :some_args
    end
    
    describe "generate" do
      it "should " do
        @generator.generate
      end
    end
    
  end
  
end