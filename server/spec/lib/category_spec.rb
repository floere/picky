require 'spec_helper'

describe Picky::Category do

  let(:index) { Picky::Index.new :some_index }

  context 'default parameters' do
    let(:category) { described_class.new :some_category, index }

    it 'should set defaults correctly' do
      category.exact.weight_strategy.should == Picky::Generators::Weights::Default
      category.exact.partial_strategy.should be_kind_of(Picky::Generators::Partial::None)
      category.exact.similarity_strategy.should == Picky::Generators::Similarity::Default

      category.partial.weight_strategy.should be_kind_of(Picky::Generators::Weights::Logarithmic)
      category.partial.partial_strategy.should == Picky::Generators::Partial::Default
      category.partial.similarity_strategy.should be_kind_of(Picky::Generators::Similarity::None)

      category.exact.similarity_strategy.should == Picky::Generators::Similarity::Default

      category.partial.similarity_strategy.should be_kind_of(Picky::Generators::Similarity::None)

      category.instance_variable_get(:@symbols).should == nil
    end
  end

  context 'tokenizer' do
    context 'options hash' do
      let(:category) { described_class.new :some_category, index, indexing: { splits_text_on: /\t/ } }
      it 'creates a tokenizer' do
        category.tokenizer.tokenize("hello\tworld").should == [['hello', 'world'], ['hello', 'world']]
      end
    end
    context 'tokenizer' do
      let(:tokenizer) do
        Class.new do
          def tokenize text
            ['unmoved', 'by', 'your', 'texts']
          end
        end.new
      end
      let(:category) { described_class.new :some_category, index, indexing: tokenizer }
      it 'creates a tokenizer' do
        category.tokenizer.tokenize("hello\tworld").should == ['unmoved', 'by', 'your', 'texts']
      end
    end
    context 'invalid tokenizer' do
      it 'raises with a nice error message' do
        expect {
          described_class.new :some_category, index, indexing: Object.new
        }.to raise_error(<<-ERROR)
indexing options for some_index:some_category should be either
* a Hash
or
* an object that responds to #tokenize(text) => [[token1, ...], [original1, ...]]
ERROR
      end
    end
  end

end