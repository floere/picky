require 'spec_helper'

describe Backend do
  
  context 'default options' do
    before(:each) do
      @backend = Backend.new
    end
    describe 'get' do
      it 'calls Net::HTTP.get' do
        Net::HTTP.should_receive(:get).once.with("localhost", "/admin", 8080)
        
        @backend.get 
      end
      it 'calls Net::HTTP.get' do
        Net::HTTP.should_receive(:get).once.with("localhost", "/admin?some_option=some_value", 8080)
        
        @backend.get :some_option => :some_value
      end
    end
  end
  context 'specific options' do
    before(:each) do
      @backend = Backend.new :host => 'some_host', :port => 1234, :path => '/some/path'
    end
    describe 'get' do
      it 'calls Net::HTTP.get' do
        Net::HTTP.should_receive(:get).once.with("some_host", "/some/path", 1234)
        
        @backend.get 
      end
      it 'calls Net::HTTP.get' do
        Net::HTTP.should_receive(:get).once.with("some_host", "/some/path?some_option=some_value", 1234)
        
        @backend.get :some_option => :some_value
      end
    end
  end
  
end
