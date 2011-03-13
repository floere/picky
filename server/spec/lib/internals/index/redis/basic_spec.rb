require 'spec_helper'

describe Internals::Index::Redis::Basic do
  
  let(:redis) { described_class.new "some_namespace" }

  describe 'load, retrieve, backup, delete' do
    it 'is nothing they do (at least on the backend)' do
      redis.should_receive(:backend).never
      
      redis.load
      redis.retrieve
      redis.backup
      redis.delete
    end
  end
  
  describe 'cache_small?' do
    context 'size 0' do
      before(:each) do
        redis.stub! :size => 0
      end
      it 'is small' do
        redis.cache_small?.should == true
      end
    end
    context 'size 1' do
      before(:each) do
        redis.stub! :size => 1
      end
      it 'is not small' do
        redis.cache_small?.should == false
      end
    end
  end
  
  describe 'cache_ok?' do
    context 'size 0' do
      before(:each) do
        redis.stub! :size => 0
      end
      it 'is not ok' do
        redis.cache_ok?.should == false
      end
    end
    context 'size 1' do
      before(:each) do
        redis.stub! :size => 1
      end
      it 'is ok' do
        redis.cache_ok?.should == true
      end
    end
  end
  
  describe "size" do
    it 'delegates to the backend' do
      backend = stub :backend
      redis.stub! :backend => backend
      
      backend.should_receive(:dbsize).once.with
      
      redis.size
    end
  end
  
end