require 'spec_helper'

describe Picky::Category do

  let(:index) { Picky::Index.new :some_index }
  let(:category) { described_class.new :some_category, index }

  it 'should set defaults correctly' do
    category.exact.weights_strategy.should == Picky::Generators::Weights::Default
    category.exact.partial_strategy.should be_kind_of(Picky::Generators::Partial::None)
    category.exact.similarity_strategy.should == Picky::Generators::Similarity::Default

    category.partial.weights_strategy.should be_kind_of(Picky::Generators::Weights::Logarithmic)
    category.partial.partial_strategy.should == Picky::Generators::Partial::Default
    category.partial.similarity_strategy.should be_kind_of(Picky::Generators::Similarity::None)

    category.exact.similarity_strategy.should == Picky::Generators::Similarity::Default

    category.partial.similarity_strategy.should be_kind_of(Picky::Generators::Similarity::None)
  end

end