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
    describe "harakiri" do
      it "should kill the process after 50 harakiri calls" do
        Process.should_receive(:kill).once
        
        50.times { @harakiri.harakiri }
      end
      it "should not kill the process after 49 harakiri calls" do
        Process.should_receive(:kill).never
        
        49.times { @harakiri.harakiri }
      end
    end
    describe "call" do
      before(:each) do
        @app.stub! :call
        @app.stub! :harakiri
      end
      it "calls harakiri" do
        @harakiri.should_receive(:harakiri).once.with
        
        @harakiri.call :env
      end
      it "calls the app" do
        @app.should_receive(:call).once.with :env
        
        @harakiri.call :env
      end
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