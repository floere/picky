require 'spec_helper'

describe Helpers::GC do
  include Helpers::GC

  before(:each) do
    ::GC.stub!(:disable)
    ::GC.stub!(:enable)
    ::GC.stub!(:start)
  end

  describe "block calling" do
    it 'should call the block' do
      inside_block = mock :inside
      inside_block.should_receive(:call).once

      disabled do
        inside_block.call
      end
    end
    it 'should call the block' do
      inside_block = mock :inside
      inside_block.should_receive(:call).once

      gc_disabled do
        inside_block.call
      end
    end
  end

  describe "gc calls" do
    after(:each) do
      disabled {}
    end
    it 'should disable the garbage collector' do
      ::GC.should_receive(:disable)
    end
    it 'should enable the garbage collector' do
      ::GC.should_receive(:enable)
    end
    it 'should start the garbage collector' do
      ::GC.should_receive(:start)
    end
    it 'should disable the gc, call the block, enable the gc and start the gc' do
      ::GC.should_receive(:disable).ordered
      ::GC.should_receive(:enable).ordered
      ::GC.should_receive(:start).ordered
    end
  end

  describe "gc calls" do
    after(:each) do
      gc_disabled {}
    end
    it 'should disable the garbage collector' do
      ::GC.should_receive(:disable)
    end
    it 'should enable the garbage collector' do
      ::GC.should_receive(:enable)
    end
    it 'should start the garbage collector' do
      ::GC.should_receive(:start)
    end
    it 'should disable the gc, call the block, enable the gc and start the gc' do
      ::GC.should_receive(:disable).ordered
      ::GC.should_receive(:enable).ordered
      ::GC.should_receive(:start).ordered
    end
  end

end