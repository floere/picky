require 'spec_helper'

describe Picky::Bundle do
  before(:each) do
    @index    = Picky::Index.new :some_index
    @category = Picky::Category.new :some_category, @index
  end
  let(:bundle) do
    described_class.new :some_name,
                        @category,
                        Picky::Generators::Weights::Default,
                        Picky::Generators::Partial::Default,
                        Picky::Generators::Similarity::DoubleMetaphone.new(3)
  end

  describe 'identifier' do
    it 'is correct' do
      bundle.identifier.should == :'some_index:some_category:some_name'
    end
  end

  describe 'index_path' do
    it 'is correct' do
      bundle.index_path(:some_type).should == 'spec/temp/index/test/some_index/some_category_some_name_some_type'
    end
    it 'is correct' do
      bundle.index_path.should == 'spec/temp/index/test/some_index/some_category_some_name'
    end
  end
end
