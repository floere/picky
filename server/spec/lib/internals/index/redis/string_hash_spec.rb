require 'spec_helper'

describe Internals::Index::Redis::StringHash do
  
  let(:index) { described_class.new :some_namespace }
    
  describe 'collection' do
    it 'raises' do
      expect { index.collection :anything }.to raise_error("Can't retrieve a collection from a StringHash. Use Index::Redis::ListHash.")
    end
  end
  describe 'member' do
    before(:each) do
      @backend = stub :backend
      index.stub! :backend => @backend
    end
    it 'delegates to the backend' do
      @backend.should_receive(:hget).once.with :some_namespace, :some_symbol
      
      index.member :some_symbol
    end
    it 'returns whatever it gets from the backend' do
      @backend.should_receive(:hget).any_number_of_times.and_return :some_result
      
      index.member(:anything).should == :some_result
    end
  end
  
end