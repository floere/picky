require 'spec_helper'

describe Backend::Redis::ListHash do
  
  let(:index) { described_class.new :some_namespace }
  
  describe 'member' do
    it 'raises an error' do
      expect {
        index.member :some_sym
      }.to raise_error("Can't retrieve single value :some_sym from a Redis ListHash. Use Indexes::Redis::StringHash.")
    end
  end
  
  describe 'collection' do
    it 'returns whatever comes back from the backend' do
      backend = stub :backend
      index.should_receive(:backend).and_return backend
      
      backend.stub! :zrange => :some_lrange_result
      
      index.collection(:anything).should == :some_lrange_result
    end
    it 'calls the right method on the backend' do
      backend = stub :backend
      index.should_receive(:backend).and_return backend
      
      backend.should_receive(:zrange).once.with "some_namespace:some_sym", 0, -1
      
      index.collection :some_sym
    end
  end
  
  describe 'to_s' do
    it 'returns the cache path with the default file extension' do
      index.to_s.should == 'Backend::Redis::ListHash(some_namespace:*)'
    end
  end
  
end