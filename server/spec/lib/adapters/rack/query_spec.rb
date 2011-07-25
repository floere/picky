# encoding: utf-8
#
require 'spec_helper'

describe Picky::Adapters::Rack::Search do
  
  before(:each) do
    @query   = stub :query
    @adapter = described_class.new @query
  end
  
  describe 'to_app' do
    it 'works' do
      lambda { @adapter.to_app }.should_not raise_error
    end
    it 'returns the right thing' do
      @adapter.to_app.should respond_to(:call)
    end
  end
  
  describe 'extracted' do
    it 'extracts the query' do
      @adapter.extracted('query' => 'some_query')[0].should == 'some_query'
    end
    it 'extracts the default ids amount' do
      @adapter.extracted('query' => 'some_query')[1].should == 20
    end
    it 'extracts the default offset' do
      @adapter.extracted('query' => 'some_query')[2].should == 0
    end
    it 'extracts a given ids amount' do
      @adapter.extracted('query' => 'some_query', 'ids' => '123')[1].should == 123
    end
    it 'extracts a given offset' do
      @adapter.extracted('query' => 'some_query', 'offset' => '123')[2].should == 123
    end
  end
  
end