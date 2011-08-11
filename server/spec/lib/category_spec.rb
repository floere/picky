require 'spec_helper'

describe Picky::Category do
  
  let(:index) { Picky::Indexes::Memory.new :some_index }
  let(:category) { described_class.new :some_category, index }
  
  it 'should set defaults correctly' do
    category.indexing_exact.weights_strategy.should == Picky::Generators::Weights::Default
    category.indexing_exact.partial_strategy.should be_kind_of(Picky::Generators::Partial::None)
    category.indexing_exact.similarity_strategy.should == Picky::Generators::Similarity::Default
    
    category.indexing_partial.weights_strategy.should be_kind_of(Picky::Generators::Weights::Logarithmic)
    category.indexing_partial.partial_strategy.should == Picky::Generators::Partial::Default
    category.indexing_partial.similarity_strategy.should be_kind_of(Picky::Generators::Similarity::None)
    
    category.indexed_exact.similarity_strategy.should == Picky::Generators::Similarity::Default
    
    category.indexed_partial.similarity_strategy.should be_kind_of(Picky::Generators::Similarity::None)
  end
  
end