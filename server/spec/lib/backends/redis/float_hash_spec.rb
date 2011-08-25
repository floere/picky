require 'spec_helper'

describe Picky::Backends::Redis::FloatHash do
  
  let(:redis_backend) { stub :redis_backend }
  let(:backend) { described_class.new :some_namespace, redis_backend }
    
  describe 'dump' do
    it 'dumps correctly' do
      redis_backend.should_receive(:del).once.ordered.with  :some_namespace
      redis_backend.should_receive(:hset).once.ordered.with :some_namespace, :a, 1
      redis_backend.should_receive(:hset).once.ordered.with :some_namespace, :b, 2
      redis_backend.should_receive(:hset).once.ordered.with :some_namespace, :c, 3
      
      backend.dump a: 1, b: 2, c: 3
    end
  end
  
  describe 'member' do
    before(:each) do
      @actual_backend = stub :actual_backend
      backend.stub! :backend => @actual_backend
    end
    it 'delegates to the backend' do
      @actual_backend.should_receive(:hget).once.with :some_namespace, :some_symbol
      
      backend[:some_symbol]
    end
    it 'returns whatever it gets from the backend' do
      @actual_backend.should_receive(:hget).any_number_of_times.and_return '1.23'
      
      backend[:anything].should == 1.23
    end
  end
  
  describe 'to_s' do
    it 'returns the cache path with the default file extension' do
      backend.to_s.should == 'Picky::Backends::Redis::FloatHash(some_namespace:*)'
    end
  end
  
end