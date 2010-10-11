# encoding: utf-8
require 'spec_helper'

describe Rack::Harakiri do
  before(:each) do
    @app = stub :app
  end
  context "defaults" do
    before(:each) do
      @harakiri = Rack::Harakiri.new @app
    end
    it "should quit after an amount of requests" do
      @harakiri.quit_after_requests.should == 50
    end
  end
  context "with harakiri set" do
    before(:each) do
      Rack::Harakiri.after = 100
      @harakiri = Rack::Harakiri.new @app
    end
    after(:each) do
      Rack::Harakiri.after = nil
    end
    it "should quit after an amount of requests" do
      @harakiri.quit_after_requests.should == 100
    end
  end
  
end