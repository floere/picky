# encoding: utf-8
#
require 'spec_helper'

describe Adapters::Rack::LiveParameters do
  
  before(:each) do
    @live_parameters = stub :live_parameters
    @adapter         = Adapters::Rack::LiveParameters.new @live_parameters
  end
  
  describe 'to_app' do
    it 'works' do
      lambda { @adapter.to_app }.should_not raise_error
    end
    it 'returns the right thing' do
      @adapter.to_app.should respond_to(:call)
    end
  end
  
end