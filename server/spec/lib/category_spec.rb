require 'spec_helper'

describe Category do
  
  let(:index) { Indexes::Memory.new :some_index, source: [] }
  let(:category) { described_class.new :some_category, index }
  
  it 'should set defaults correctly' do
    category.indexing_exact.weights_strategy.should == Generators::Weights::Default
    category.indexing_exact.partial_strategy.should be_kind_of(Generators::Partial::None)
    category.indexing_exact.similarity_strategy.should == Generators::Similarity::Default
    
    category.indexing_partial.weights_strategy.should be_kind_of(Generators::Weights::Logarithmic)
    category.indexing_partial.partial_strategy.should == Generators::Partial::Default
    category.indexing_partial.similarity_strategy.should be_kind_of(Generators::Similarity::None)
    
    category.indexed_exact.similarity_strategy.should == Generators::Similarity::Default
    
    category.indexed_partial.similarity_strategy.should be_kind_of(Generators::Similarity::None)
  end
  
end