# encoding: utf-8
#
require 'spec_helper'

describe Application do
  
  describe "integration" do
    it "should run ok" do
      lambda {
        # TODO Add all possible cases.
        #
        class TestApplication < Application
          indexing.removes_characters(/[^a-zA-Z0-9\s\/\-\"\&\.]/)
          indexing.stopwords(/\b(and|the|of|it|in|for)\b/)
          indexing.splits_text_on(/[\s\/\-\"\&\.]/)
          
          books_index = index Sources::DB.new('SELECT id, title, author, isbn13 as isbn FROM books', :file => 'app/db.yml'),
                              field(:title, :similarity => Similarity::DoubleLevenshtone.new(3)), # Up to three similar title word indexed.
                              field(:author),
                              field(:isbn,  :partial => Partial::None.new) # Partially searching on an ISBN makes not much sense.
                              
          # Note that Picky needs the following characters to
          # pass through, as they are control characters: *"~:
          #
          querying.removes_characters(/[^a-zA-Z0-9\s\/\-\,\&\"\~\*\:]/)
          querying.stopwords(/\b(and|the|of|it|in|for)\b/)
          querying.split_text_on(/[\s\/\-\,\&]+/)
          querying.maximum_tokens 5
          
          full = Query::Full.new books_index
          live = Query::Live.new books_index
          
          route %r{^/books/full} => full
          route %r{^/books/live} => live
        end
      }.should_not raise_error
    end
  end
  
  describe 'routing' do
    it 'should be there' do
      lambda { Application.routing }.should_not raise_error
    end
    it "should return a new Routing instance" do
      Application.routing.should be_kind_of(Routing)
    end
    it "should cache the instance" do
      Application.routing.should == Application.routing
    end
  end
  
  describe 'call' do
    before(:each) do
      @routes = stub :routes
      Application.stub! :routing => @routes
    end
    it 'should delegate' do
      @routes.should_receive(:call).once.with :env
      
      Application.call :env
    end
  end
  
  describe "indexes" do
    
  end
  describe "indexes_configuration" do
    it 'should be there' do
      lambda { Application.indexes_configuration }.should_not raise_error
    end
    it "should return a new Routing instance" do
      Application.indexes_configuration.should be_kind_of(Configuration::Indexes)
    end
    it "should cache the instance" do
      Application.indexes_configuration.should == Application.indexes_configuration
    end
  end
  
  describe "queries" do
    
  end
  describe "queries_configuration" do
    it 'should be there' do
      lambda { Application.queries_configuration }.should_not raise_error
    end
    it "should return a new Routing instance" do
      Application.queries_configuration.should be_kind_of(Configuration::Queries)
    end
    it "should cache the instance" do
      Application.queries_configuration.should == Application.queries_configuration
    end
  end
  
end