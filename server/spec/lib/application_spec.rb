# encoding: utf-8
#
require 'spec_helper'

describe Application do
  
  describe 'routing' do
    it 'should be there' do
      lambda { Application.routing }.should_not raise_error
    end
    it "should return a new Routing instance" do
      Application.routing.should be_kind_of(Routing)
    end
    it "should cache the instance" do
      Application.routing.should == Application.routing
    end
  end
  
  describe 'call' do
    before(:each) do
      @routes = stub :routes
      Application.stub! :routing => @routes
    end
    it 'should delegate' do
      @routes.should_receive(:call).once.with :env
      
      Application.call :env
    end
  end
  
  describe "indexes" do
    
  end
  describe "indexes_configuration" do
    it 'should be there' do
      lambda { Application.indexes_configuration }.should_not raise_error
    end
    it "should return a new Routing instance" do
      Application.indexes_configuration.should be_kind_of(Configuration::Indexes)
    end
    it "should cache the instance" do
      Application.indexes_configuration.should == Application.indexes_configuration
    end
  end
  
  describe "queries" do
    
  end
  describe "queries_configuration" do
    it 'should be there' do
      lambda { Application.queries_configuration }.should_not raise_error
    end
    it "should return a new Routing instance" do
      Application.queries_configuration.should be_kind_of(Configuration::Queries)
    end
    it "should cache the instance" do
      Application.queries_configuration.should == Application.queries_configuration
    end
  end
  
end