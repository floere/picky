require 'spec_helper'

describe Internals::Indexed::Bundle::Redis do

  before(:each) do
    @backend = stub :backend
    
    Internals::Index::Redis.stub! :new => @backend
    
    @index        = stub :index, :name => :some_index
    @category     = Internals::Indexed::Category.new :some_category, @index
    
    @similarity   = stub :similarity
    @bundle       = described_class.new :some_name, @category, @similarity
  end
  
  describe 'ids' do
    it 'delegates to the backend' do
      @backend.should_receive(:ids).once.with :some_sym
      
      @bundle.ids :some_sym
    end
  end
  
  describe 'weight' do
    it 'delegates to the backend' do
      @backend.should_receive(:weight).once.with :some_sym
      
      @bundle.weight :some_sym
    end
  end
  
  describe '[]' do
    it 'delegates to the backend' do
      @backend.should_receive(:setting).once.with :some_sym
      
      @bundle[:some_sym]
    end
  end
  
end