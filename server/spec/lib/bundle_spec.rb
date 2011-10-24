require 'spec_helper'

describe Picky::Bundle do

  before(:each) do
    @index    = Picky::Index.new :some_index
    @category = Picky::Category.new :some_category, @index
    @similarity = Picky::Similarity::DoubleMetaphone.new 3
  end
  let(:bundle) { described_class.new :some_name, @category, Picky::Backends::Memory.new, Picky::Generators::Weights::Default, @similarity }
  
  describe 'identifier' do
    it 'is correct' do
      bundle.identifier.should == 'test:some_index:some_category:some_name'
    end
  end
  
  describe 'index_path' do
    it 'is correct' do
      bundle.index_path(:some_type).should == 'spec/test_directory/index/test/some_index/some_category_some_name_some_type'
    end
    it 'is correct' do
      bundle.index_path.should == 'spec/test_directory/index/test/some_index/some_category_some_name'
    end
  end
  
end