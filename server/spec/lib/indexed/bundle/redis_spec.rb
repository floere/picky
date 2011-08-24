require 'spec_helper'

describe Picky::Indexed::Bundle::Redis do

  before(:each) do
    @backend = stub :backend
    
    Picky::Backend::Redis.stub! :new => @backend
    
    @index        = Picky::Indexes::Memory.new :some_index
    @category     = Picky::Category.new :some_category, @index
    
    @similarity   = stub :similarity
    @bundle       = described_class.new :some_name, @category, @similarity
  end
  
end