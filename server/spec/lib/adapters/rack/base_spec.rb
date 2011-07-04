# encoding: utf-8
#
require 'spec_helper'

describe Adapters::Rack::Base do
  
  before(:each) do
    @adapter = described_class.new
  end
  
  describe 'respond_with' do
    describe 'by default' do
      it 'uses json' do
        @adapter.respond_with('response').should ==
          [200, { 'Content-Type' => 'application/json', 'Content-Length' => '8' }, ['response']]
      end
    end
    it 'adapts the content length' do
      @adapter.respond_with('123').should ==
        [200, { 'Content-Type' => 'application/json', 'Content-Length' => '3' }, ['123']]
    end
  end
  
end