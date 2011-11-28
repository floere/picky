require 'spec_helper'

describe Picky::Backends::SQLite::DirectlyManipulable do

  let(:client) { stub :client }
  let(:backend) { stub :backend, client: client, namespace: 'some:namespace' }
  let(:list) do
    described_class.make [1,2], backend, 'some:key'
  end

  context 'stubbed backend' do
    before(:each) do
      backend.stub! :[]
    end
    it 'calls the right client method' do
      backend.should_receive(:[]=).once.with 'some:key', [1,2,3]

      list << 3
    end
    it 'calls the right client method' do
      backend.should_receive(:[]=).once.with 'some:key', [3,1,2]

      list.unshift 3
    end
    it 'calls the right client method' do
      backend.should_receive(:[]=).once.with 'some:key', [2]

      list.delete 1
    end
    it 'calls the right client method' do
      client.should_receive(:zrem).never

      list.delete 5
    end
  end

  context 'stubbed client/backend' do
    before(:each) do
      backend.stub! :[]=
    end
    it 'behaves like an ordinary Array' do
      list << 3

      list.should == [1,2,3]
    end
    it 'behaves like an ordinary Array' do
      list.unshift 3

      list.should == [3,1,2]
    end
    it 'behaves like an ordinary Array' do
      list.delete 1

      list.should == [2]
    end
    it 'behaves like an ordinary Array' do
      list.delete 5

      list.should == [1,2]
    end
  end

end