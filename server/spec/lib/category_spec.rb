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

      category.instance_variable_get(:@symbol_keys).should == nil
    end
    
    context '#==' do
      it 'is identical on the same thing' do
        category.should == category
      end
      it 'looks only at index name and category name' do
        category.should == described_class.new(:some_category, index)
      end
      it 'looks only at index name and category name' do
        category.should_not == described_class.new(:some_other_category, index)
      end
      it 'results in a correct #include?' do
        [category].include?(described_class.new(:some_category, index)).should == true
      end
    end
  end
  
  context 'directories' do
    let(:category) { described_class.new :some_category, index }
    it 'is correct' do
      category.prepared_index_path.should == 'spec/temp/index/test/some_index/some_category'
    end
  end
  
  describe 'options' do
    let(:category) { described_class.new :some_category, index }
    it 'warns on wrong options' do
      category.should_receive(:warn).once.with <<-WARNING

Warning: Category options {:weights=>:some_weight} for category some_category contain an unknown option.
         Working options are: [:hints, :indexing, :partial, :qualifier, :qualifiers, :ranging, :similarity, :source, :tokenize, :tokenizer, :weight].
WARNING
      
      category.warn_if_unknown weights: :some_weight
    end
    it 'does not warn on right options' do
      category.should_receive(:warn).never
      
      category.warn_if_unknown weight: :some_weight
    end
  end

  context 'tokenizer' do
    context 'options hash' do
      let(:category) { described_class.new :some_category, index, indexing: { splits_text_on: /\t/ } }
      it 'creates a tokenizer' do
        category.tokenizer.tokenize("hello\tworld").should == [%w[hello world], %w[hello world]]
      end
    end
    context 'tokenizer' do
      let(:tokenizer) do
        Class.new do
          def tokenize(text)
            %w[unmoved by your texts]
          end
        end.new
      end
      let(:category) { described_class.new :some_category, index, indexing: tokenizer }
      it 'creates a tokenizer' do
        category.tokenizer.tokenize("hello\tworld").should == %w[unmoved by your texts]
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
* an object that responds to #tokenize(text) => [[token1, token2, ...], [original1, original2, ...]]
ERROR
      end
    end
  end

end