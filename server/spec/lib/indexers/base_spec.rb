require 'spec_helper'

describe Indexers::Base do

  let(:some_index_or_category) { stub :some_index_or_category, :name => 'some index or category' }
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
  end
  
  describe 'index' do
    it 'messages, then processed' do
      indexer.should_receive(:start_indexing_message).once.with.ordered
      indexer.should_receive(:prepare).once.with(:categories).ordered
      indexer.should_receive(:process).once.with(:categories).ordered
      indexer.should_receive(:finish_indexing_message).once.with.ordered
      
      indexer.index :categories
    end
  end
  
  describe 'prepare' do
    it 'calls a certain method on each category' do
      some_index_or_category.stub! :source
      
      category1 = stub :category1
      category2 = stub :category2
      category3 = stub :category3
      
      categories = [category1, category2, category3]
      
      categories.each do |category|
        category.should_receive(:prepare_index_directory).once.with
      end
      
      indexer.prepare categories
    end
  end
  
end