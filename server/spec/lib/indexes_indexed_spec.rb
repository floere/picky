require 'spec_helper'

describe Picky::Indexes do

  context 'after initialize' do
    let(:indexes) { described_class.new }
    it 'has an empty mapping' do
      indexes.index_mapping.should == {}
    end
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
    describe '[]' do
      it 'should use the mapping' do
        indexes[:index2].should == @index2
      end
      it 'should allow strings' do
        indexes['index1'].should == @index1
      end
    end
    describe 'register' do
      it 'should have indexes' do
        indexes.indexes.should == [@index1, @index2]
      end
      it 'should have a mapping' do
        indexes.index_mapping.should == { :index1 => @index1, :index2 => @index2 }
      end
    end
    describe 'clear' do
      it 'clears the indexes' do
        indexes.clear_indexes

        indexes.indexes.should == []
      end
      it 'clears the mapping' do
        indexes.clear_indexes

        indexes.index_mapping.should == {}
      end
    end
    describe 'load' do
      it 'calls load on each in order' do
        @index1.should_receive(:load).once.with(no_args).ordered
        @index2.should_receive(:load).once.with(no_args).ordered

        indexes.load
      end
    end
  end

end