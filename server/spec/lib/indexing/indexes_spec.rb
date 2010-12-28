require 'spec_helper'

describe Indexing::Indexes do
  
  before(:each) do
    @indexes = Indexing::Indexes.new
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
      @indexes.register :some_index
      
      @indexes.clear
      
      @indexes.indexes.should == []
    end
  end
  
  describe 'register' do
    it 'adds the given index to the indexes' do
      @indexes.register :some_index
      
      @indexes.indexes.should == [:some_index]
    end
  end
  
end