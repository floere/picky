require 'spec_helper'

describe Picky::Indexes do

  before(:each) do
    @index   = double :some_index, name: :some_index
    @indexes = described_class.instance
  end

  describe 'clear_indexes' do
    it 'clears the indexes' do
      @indexes.register @index

      @indexes.clear_indexes

      @indexes.indexes.should == []
    end
  end

  describe 'register' do
    it 'adds the given index to the indexes' do
      @indexes.clear_indexes
      
      described_class.register @index

      @indexes.indexes.should == [@index]
    end
  end

end
