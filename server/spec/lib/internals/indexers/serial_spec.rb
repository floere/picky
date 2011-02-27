require 'spec_helper'

describe Indexers::Serial do

  before(:each) do
    @index         = stub :index, :name => :some_index
    @category      = stub :category, :name => :some_category
    @configuration = Configuration::Index.new @index, @category
    
    @source    = stub :source
    @tokenizer = stub :tokenizer
    @indexer = Indexers::Serial.new @configuration, @source, @tokenizer
    @indexer.stub! :timed_exclaim
  end
  
  describe 'key_format' do
    context 'source has key_format' do
      before(:each) do
        @source.stub! :key_format => :some_key_format
      end
      it 'returns what the source returns' do
        @indexer.key_format.should == :some_key_format
      end
    end
    context 'source does not have key_format' do
      before(:each) do
        @source.stub! :key_format => nil
      end
      it 'returns :to_i' do
        @indexer.key_format.should == :to_i
      end
    end
  end
  
  describe "tokenizer" do
    it "returns the right one" do
      @indexer.tokenizer.should == @tokenizer
    end
  end
  
  describe "indexing_message" do
    it "informs the user about what it is going to index" do
      @indexer.should_receive(:timed_exclaim).once.with 'INDEX some_index some_category'
      
      @indexer.indexing_message
    end
  end
  
  describe "tokenizer" do
    it "returns it" do
      @indexer.should_receive(:tokenizer).once.with
      
      @indexer.tokenizer
    end
  end
  
  describe "index" do
    it "should execute! the indexer" do
      @indexer.should_receive(:process).once.with
      
      @indexer.index
    end
  end
  
  describe "source" do
    it "returns the one given to is" do
      @indexer.source.should == @source
    end
  end
  
  describe "raise_no_source" do
    it "should raise" do
      lambda { @indexer.raise_no_source }.should raise_error(Indexers::NoSourceSpecifiedException)
    end
  end
  
  describe "chunked" do
    
  end
  
end