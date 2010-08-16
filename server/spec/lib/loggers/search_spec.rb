# encoding: utf-8
#
require 'spec_helper'

describe Loggers::Search do
  
  before(:each) do
    @destination = stub :destination
    @logger      = Loggers::Search.new @destination
  end
  describe "log" do
    it "should delegate to info" do
      @destination.should_receive(:info).once.with 'test'
      
      @logger.log 'test'
    end
  end
  
end