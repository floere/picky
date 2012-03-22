require 'spec_helper'

describe Picky::Client do
  
  let(:client) { described_class.new path: '/' }
  
  describe 'replace' do
    it 'delegates to the request method' do
      client.should_receive(:send_off).once.with anything, :some_index_name, :some_data
    
      client.replace :some_index_name, :some_data
    end
  end
  
  describe 'remove' do
    it 'delegates to the request method' do
      client.should_receive(:send_off).once.with anything, :some_index_name, :some_data
    
      client.remove :some_index_name, :some_data
    end
  end
  
end