require 'spec_helper'

describe Picky::Indexers::Base do

  let(:some_index_or_category) { stub :some_index_or_category, :name => 'some_index_or_category' }
  let(:indexer) { described_class.new some_index_or_category }

  describe 'index_or_category' do
    it 'returns the right thing' do
      indexer.index_or_category.should == some_index_or_category
    end
  end

  describe 'source' do
    it 'delegates it to the index or category' do
      some_index_or_category.should_receive(:source).once.with

      indexer.source
    end
    it 'raises when none is there' do
      some_index_or_category.should_receive(:source).any_number_of_times.and_return

      indexer.stub! :process

      expect {
        indexer.index []
      }.to raise_error("Trying to index without a source for some_index_or_category.")
    end
  end

  describe 'index' do
    before(:each) do
      some_index_or_category.should_receive(:source).any_number_of_times.and_return :some_source
    end
    it 'processes' do
      categories = stub :categories, :empty => nil, :cache => nil

      indexer.should_receive(:process).once.with categories

      indexer.index categories
    end
    it 'calls the right methods on the categories' do
      indexer.stub! :process

      categories = stub :categories

      categories.should_receive(:empty).once.ordered
      categories.should_receive(:cache).once.ordered

      indexer.index categories
    end
  end

end