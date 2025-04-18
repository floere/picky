require 'spec_helper'

describe Picky::Backends::Redis::Basic do
  let(:client) { double :client }

  context 'without options' do
    let(:backend) { described_class.new client, :some_namespace }

    describe 'load, retrieve, delete' do
      it 'is nothing they do (at least on the backend)' do
        backend.should_receive(:client).never

        backend.load false
        backend.retrieve
      end
    end

    describe 'empty' do
      it 'returns the container that is used for backending' do
        backend.empty.should == {}
      end
    end

    describe 'initial' do
      it 'is correct' do
        backend.initial.should == {}
      end
    end

    describe 'to_s' do
      it 'returns the cache path with the default file extension' do
        backend.to_s.should == 'Picky::Backends::Redis::Basic(some_namespace:*)'
      end
    end
  end

  context 'with options' do
    let(:backend) do
      described_class.new client,
                          :some_namespace,
                          empty: [],
                          initial: []
    end

    describe 'empty' do
      it 'returns the container that is used for backending' do
        backend.empty.should == []
      end
    end

    describe 'initial' do
      it 'is correct' do
        backend.initial.class.should == Array
      end
    end
  end
end
