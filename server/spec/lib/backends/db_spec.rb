# encoding: utf-8
require 'spec_helper'

describe DB do
  
  describe "configured" do
    it "returns a subclass of AR::Base" do
      DB.configured(:some => :thing).should < ActiveRecord::Base
    end
    it "should be an abstract class" do
      DB.configured(:some => :thing).should be_abstract_class
    end
    it "should answer connect" do
      lambda { DB.configured(:some => :thing).connect }.should_not raise_error
    end
    it "should answer configure" do
      lambda { DB.configured(:some => :thing).configure(:some => :other_thing) }.should_not raise_error
    end
  end
  
  describe "configure" do
    
  end
  
  describe "connect" do
    
  end
  
end