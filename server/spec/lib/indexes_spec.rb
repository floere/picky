require 'spec_helper'

describe Indexes do
  
  before(:each) do
    @index   = stub :some_index, :name => :some_index
    @indexes = described_class.new
  end
  
  describe 'indexes' do
    it 'exists' do
      lambda { @indexes.indexes }.should_not raise_error
    end
    it 'is empty by default' do
      @indexes.indexes.should be_empty
    end
  end
  
  describe 'clear' do
    it 'clears the indexes' do
      @indexes.register @index
      
      @indexes.clear
      
      @indexes.indexes.should == []
    end
  end
  
  describe 'register' do
    it 'adds the given index to the indexes' do
      @indexes.register @index
      
      @indexes.indexes.should == [@index]
    end
  end
  
end