require 'spec_helper'

describe Internals::Indexed::Wrappers::Bundle::Wrapper do
  
  before(:each) do
    @bundle      = stub :bundle
    
    @calculation = described_class.new @bundle
  end
  
  describe 'ids' do
    it 'calls bundle#ids correctly' do
      @bundle.should_receive(:ids).once.with :some_sym
      
      @calculation.ids :some_sym
    end
  end
  
  describe 'weight' do
    it 'calls bundle#ids correctly' do
      @bundle.should_receive(:weight).once.with :some_sym
      
      @calculation.weight :some_sym
    end
  end
  
end