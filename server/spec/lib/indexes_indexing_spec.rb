# encoding: utf-8
#
require 'spec_helper'

describe Picky::Indexes do

  context 'after initialize' do
    let(:indexes) { described_class.new }
    it 'has no indexes' do
      indexes.indexes.should == []
    end
  end

  describe 'methods' do
    let(:indexes) { described_class.new }
    before(:each) do
      @index1 = double :index1, :name => :index1
      @index2 = double :index2, :name => :index2
      indexes.register @index1
      indexes.register @index2
    end
    describe 'index' do
      it 'prepares and caches each' do
        scheduler = double :scheduler, :fork? => false, :finish => nil

        @index1.should_receive(:prepare).once.with(scheduler).ordered
        @index2.should_receive(:prepare).once.with(scheduler).ordered

        @index1.should_receive(:cache).once.with(scheduler).ordered
        @index2.should_receive(:cache).once.with(scheduler).ordered

        indexes.index scheduler
      end
    end
    describe 'register' do
      it 'should have indexes' do
        indexes.indexes.should == [@index1, @index2]
      end
    end
    describe 'clear_indexes' do
      it 'clears the indexes' do
        indexes.clear_indexes

        indexes.indexes.should == []
      end
    end
    def self.it_forwards_each name
      describe name do
        it "calls #{name} on each in order" do
          @index1.should_receive(name).once.with(no_args).ordered
          @index2.should_receive(name).once.with(no_args).ordered

          indexes.send name
        end
      end
    end
    it_forwards_each :clear
  end

end