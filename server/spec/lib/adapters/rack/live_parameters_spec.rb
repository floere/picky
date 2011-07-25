# encoding: utf-8
#
require 'spec_helper'

describe Picky::Adapters::Rack::LiveParameters do
  
  let(:live_parameters) { stub :live_parameters }
  let(:adapter) { described_class.new live_parameters }
  
  describe 'to_app' do
    it 'works' do
      lambda { adapter.to_app }.should_not raise_error
    end
    it 'returns the right thing' do
      adapter.to_app.should respond_to(:call)
    end
    it 'returned lambda should call parameters on the live parameters' do
      env = { 'rack.input' => 'some input' }
      
      live_parameters.should_receive(:parameters).once.with({})
      
      adapter.to_app.call env
    end
  end
  
end