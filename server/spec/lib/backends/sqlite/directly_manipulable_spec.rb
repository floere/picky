require 'spec_helper'

describe Picky::Backends::SQLite::DirectlyManipulable do

  let(:client) { stub :client }
  let(:backend) { stub :backend, client: client, namespace: 'some:namespace' }
  let(:array) do
    array = [1,2]
    described_class.make backend, array, 'some:key'
    array
  end

  context 'stubbed backend' do
    before(:each) do
      backend.stub! :[]
    end
    it 'calls the right client method' do
      backend.should_receive(:[]=).once.with 'some:key', [1,2,3]

      array << 3
    end
    it 'calls the right client method' do
      backend.should_receive(:[]=).once.with 'some:key', [3,1,2]

      array.unshift 3
    end
    it 'calls the right client method' do
      backend.should_receive(:[]=).once.with 'some:key', [2]

      array.delete 1
    end
    it 'calls the right client method' do
      client.should_receive(:zrem).never

      array.delete 5
    end
  end

  context 'stubbed client/backend' do
    before(:each) do
      backend.stub! :[]=
    end
    it 'behaves like an ordinary Array' do
      array << 3

      array.should == [1,2,3]
    end
    it 'behaves like an ordinary Array' do
      array.unshift 3

      array.should == [3,1,2]
    end
    it 'behaves like an ordinary Array' do
      array.delete 1

      array.should == [2]
    end
    it 'behaves like an ordinary Array' do
      array.delete 5

      array.should == [1,2]
    end
  end

end