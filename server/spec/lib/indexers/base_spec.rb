require 'spec_helper'

describe Indexers::Base do

  let(:indexer) { described_class.new }
  
  describe 'index' do
    it 'messages, then processed' do
      indexer.should_receive(:indexing_message).once.with.ordered
      indexer.should_receive(:process).once.with.ordered
      
      indexer.index
    end
  end
  
end