require 'spec_helper'

describe Picky::Indexed::Bundle do

  before(:each) do
    @index        = Picky::Index.new :some_index
    @category     = Picky::Category.new :some_category, @index
    
    @similarity   = stub :similarity
    @weights      = Picky::Generators::Weights::Default
    @bundle       = described_class.new :some_name, @category, Picky::Backends::Memory.new, @weights, @similarity
  end
  
  it 'is by default empty' do
    @bundle.realtime_mapping.should == {}
  end
  it 'is by default empty' do
    @bundle.weights.should == {}
  end
  it 'is by default empty' do
    @bundle.inverted.should == {}
  end
  
  describe 'combined' do
    it 'works correctly' do
      @bundle.add 1, :title
      @bundle.add 1, :other
      @bundle.remove 1
      
      @bundle.realtime_mapping.should == {}
      @bundle.weights.should  == {}
      @bundle.inverted.should == {}
    end
    it 'works correctly' do
      @bundle.add 1, :title
      @bundle.add 2, :thing
      @bundle.add 1, :other
      @bundle.remove 1
      
      @bundle.realtime_mapping.should == { 2 => [:thing] }
      @bundle.weights.should  == { :thing => 0.0 }
      @bundle.inverted.should == { :thing => [2] }
    end
  end
  
  describe 'add' do
    it 'works correctly' do
      @bundle.add 1, :title
      
      @bundle.realtime_mapping.should == { 1 => [:title] }
      
      @bundle.add 2, :other
      
      @bundle.realtime_mapping.should == { 1 => [:title], 2 => [:other] }
      
      @bundle.add 1, :thing
      
      @bundle.realtime_mapping.should == { 1 => [:title, :thing], 2 => [:other] }
    end
    it 'works correctly' do
      @bundle.add 1, :title
      
      @bundle.weights.should  == { :title => 0.0 }
      @bundle.inverted.should == { :title => [1] }
    end
  end
  
end