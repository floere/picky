require 'spec_helper'

describe Picky::Backends::Redis::Float do
  let(:client) { double :client }
  let(:backend) { described_class.new client, 'some_namespace' }

  describe 'dump' do
    it 'dumps correctly' do
      client.should_receive(:del).once.ordered.with  'some_namespace'
      client.should_receive(:hset).once.ordered.with 'some_namespace', 'a', 1
      client.should_receive(:hset).once.ordered.with 'some_namespace', 'b', 2
      client.should_receive(:hset).once.ordered.with 'some_namespace', 'c', 3

      backend.dump 'a' => 1, 'b' => 2, 'c' => 3
    end
  end

  describe 'member' do
    it 'forwards to the backend' do
      client.should_receive(:hget).once.with 'some_namespace', 'some'

      backend['some']
    end
    it 'returns whatever it gets from the backend' do
      client.should_receive(:hget).at_least(1).and_return '1.23'

      backend['anything'].should == 1.23
    end
    it 'returns whatever it gets from the backend' do
      client.should_receive(:hget).at_least(1).and_return nil

      backend['anything'].should.nil?
    end
  end

  describe 'to_s' do
    it 'returns the cache path with the default file extension' do
      backend.to_s.should == 'Picky::Backends::Redis::Float(some_namespace:*)'
    end
  end
end
