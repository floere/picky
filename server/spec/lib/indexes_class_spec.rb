require 'spec_helper'

describe Indexes do

  before(:each) do
    @index   = stub :some_index, :name => :some_index
    @indexes = described_class.instance
  end

  describe 'clear' do
    it 'clears the indexes' do
      Indexes.register @index

      Indexes.clear

      @indexes.indexes.should == []
    end
  end

  describe 'register' do
    it 'adds the given index to the indexes' do
      Indexes.clear
      
      Indexes.register @index

      @indexes.indexes.should == [@index]
    end
  end

end