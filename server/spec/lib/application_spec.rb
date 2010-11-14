# encoding: utf-8
#
require 'spec_helper'

describe Application do
  
  describe "integration" do
    it "should run ok" do
      lambda {
        class MinimalTestApplication < Application
          books = index :books, Sources::DB.new('SELECT id, title FROM books', :file => 'app/db.yml')
          books.category :title
                              
          
          full = Query::Full.new books
          live = Query::Live.new books
          
          route %r{^/books/full} => full
          route %r{^/books/live} => live
        end
        Tokenizers::Index.default.tokenize 'some text'
        Tokenizers::Query.default.tokenize 'some text'
      }.should_not raise_error
    end
    it "should run ok" do
      lambda {
        # TODO Add all possible cases.
        #
        class TestApplication < Application
          default_indexing removes_characters:                 /[^a-zA-Z0-9\s\/\-\"\&\.]/,
                           contracts_expressions:              [/mr\.\s*|mister\s*/i, 'mr '],
                           stopwords:                          /\b(and|the|of|it|in|for)\b/,
                           splits_text_on:                     /[\s\/\-\"\&\.]/,
                           removes_characters_after_splitting: /[\.]/
                           
          default_querying removes_characters: /[^a-zA-Z0-9äöü\s\/\-\,\&\"\~\*\:]/,
                           stopwords:          /\b(and|the|of|it|in|for)\b/,
                           splits_text_on:     /[\s\/\-\,\&]+/,
                           normalizes_words:   [[/Deoxyribonucleic Acid/i, 'DNA']],
                           
                           substitutes_characters_with: CharacterSubstitution::European.new,
                           maximum_tokens: 5
          
          books_index = index :books, Sources::DB.new('SELECT id, title, author, isbn13 as isbn FROM books', :file => 'app/db.yml')
          books_index.category :title, similarity: Similarity::DoubleLevenshtone.new(3) # Up to three similar title word indexed.
          books_index.category :author
          books_index.category :isbn, partial: Partial::None.new # Partially searching on an ISBN makes not much sense.
          
          full = Query::Full.new books_index
          live = Query::Live.new books_index
          
          route %r{^/books/full} => full
          route %r{^/books/live} => live
        end
      }.should_not raise_error
    end
  end
  
  describe 'delegation' do
    it "should delegate route" do
      Application.routing.should_receive(:route).once.with :path => :query
      
      Application.route :path => :query
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
  
end