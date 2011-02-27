# encoding: utf-8
#
require 'spec_helper'

describe Internals::Adapters::Rack::LiveParameters do
  
  before(:each) do
    @live_parameters = stub :live_parameters
    @adapter         = described_class.new @live_parameters
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