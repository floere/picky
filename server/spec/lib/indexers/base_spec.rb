require 'spec_helper'

describe Indexers::Base do

  before(:each) do
    @type  = stub :type,
                  :name => :some_type,
                  :snapshot_table_name => :some_prepared_table_name
    @field = stub :field,
                  :name => :some_field_name,
                  :search_index_file_name => :some_search_index_name,
                  :indexed_name => :some_indexed_field_name
    @indexer = Indexers::Base.new @type, @field
    @indexer.stub! :indexing_message
  end
  
  describe "tokenizer" do
    it "should delegate to field" do
      @field.should_receive(:tokenizer).once.with
      
      @indexer.tokenizer
    end
  end
  
  describe 'search_index_file_name' do
    it 'should return a specific name' do
      @indexer.search_index_file_name.should == :some_search_index_name
    end
  end
  
  describe "index" do
    it "should execute! the indexer" do
      @indexer.should_receive(:process).once.with
      
      @indexer.index
    end
  end
  
  describe "source" do
    before(:each) do
      @source = stub :source
    end
    context "field has one" do
      before(:each) do
        @field.stub! :source => @source
      end
      it "should return that one" do
        @indexer.source.should == @source
      end
    end
    context "field doesn't have one" do
      before(:each) do
        @field.stub! :source => nil
      end
      it "should call raise_no_source" do
        @indexer.should_receive(:raise_no_source).once.with
        
        @indexer.source
      end
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