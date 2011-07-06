require 'spec_helper'

describe Indexers::Serial do

  before(:each) do
    @tokenizer = stub :tokenizer
    @source  = stub :source
    @category  = stub :category,
                      :identifier => :some_identifier,
                      :tokenizer => @tokenizer,
                      :source => @source
    
    @indexer = described_class.new @category
    @indexer.stub! :timed_exclaim
  end
  
  describe "indexing_message" do
    it "informs the user about what it is going to index" do
      @indexer.should_receive(:timed_exclaim).once.with '"some_identifier": Starting serial indexing.'
      
      @indexer.indexing_message
    end
  end
  
  describe "source" do
    it "returns the one given to is" do
      @indexer.source.should == @source
    end
  end
  
end