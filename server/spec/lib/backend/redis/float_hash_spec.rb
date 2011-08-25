require 'spec_helper'

describe Picky::Backends::Redis::FloatHash do
  
  let(:index) { described_class.new :some_namespace }
    
  describe 'dump' do
    let(:backend) { index.backend }
    it 'dumps correctly' do
      backend.should_receive(:hset).once.ordered.with :some_namespace, :a, 1
      backend.should_receive(:hset).once.ordered.with :some_namespace, :b, 2
      backend.should_receive(:hset).once.ordered.with :some_namespace, :c, 3
      
      index.dump a: 1, b: 2, c: 3
    end
  end
  
  describe '[]' do
    before(:each) do
      @backend = stub :backend
      index.stub! :backend => @backend
    end
    it 'delegates to the backend' do
      @backend.should_receive(:hget).once.with :some_namespace, :some_symbol
      
      index[:some_symbol]
    end
    it 'returns whatever it gets from the backend' do
      @backend.should_receive(:hget).any_number_of_times.and_return '1.23'
      
      index[:anything].should == 1.23
    end
  end
  
  describe 'to_s' do
    it 'returns the cache path with the default file extension' do
      index.to_s.should == 'Picky::Backends::Redis::FloatHash(some_namespace:*)'
    end
  end
  
end