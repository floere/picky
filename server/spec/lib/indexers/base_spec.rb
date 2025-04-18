require 'spec_helper'

describe Picky::Indexers::Base do

  let(:some_index_or_category) { double :some_index_or_category, name: 'some_index_or_category' }
  let(:indexer) { described_class.new some_index_or_category }

  describe 'index_or_category' do
    it 'returns the right thing' do
      indexer.index_or_category.should == some_index_or_category
    end
  end

  describe 'source' do
    it 'forwards it to the index or category' do
      some_index_or_category.should_receive(:source).once.with no_args

      indexer.source
    end
    it 'raises when none is there' do
      some_index_or_category.should_receive(:source).at_least(1).and_return nil

      indexer.stub :process

      expect {
        indexer.prepare Picky::Categories.new
      }.to raise_error('Trying to index without a source for some_index_or_category.')
    end
  end

  describe 'prepare' do
    before(:each) do
      some_index_or_category.should_receive(:source).at_least(1).and_return :some_source
    end
    it 'processes' do
      categories = double :categories, empty: nil, cache: nil

      indexer.should_receive(:process).once.with :some_source, categories, anything

      indexer.prepare categories
    end
    it 'calls the right methods on the categories' do
      indexer.stub :process

      categories = double :categories

      categories.should_receive(:empty).once.ordered

      indexer.prepare categories
    end
  end

end
