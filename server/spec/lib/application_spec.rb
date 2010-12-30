# encoding: utf-8
#
require 'spec_helper'

describe Application do
  
  describe "integration" do
    it "should run ok" do
      lambda {
        class MinimalTestApplication < Application
          books = index :books, Sources::DB.new('SELECT id, title FROM books', :file => 'app/db.yml')
          books.define_category :title
                              
          
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
        # Here we just test if the API can be called ok.
        #
        class TestApplication < Application
          default_indexing removes_characters:                 /[^a-zA-Z0-9\s\/\-\"\&\.]/,
                           stopwords:                          /\b(and|the|of|it|in|for)\b/,
                           splits_text_on:                     /[\s\/\-\"\&\.]/,
                           removes_characters_after_splitting: /[\.]/,
                           normalizes_words:                   [[/\$(\w+)/i, '\1 dollars']],
                           reject_token_if:                    lambda { |token| token.blank? || token == :amistad }
                           
          default_querying removes_characters: /[^a-zA-Z0-9äöü\s\/\-\,\&\"\~\*\:]/,
                           stopwords:          /\b(and|the|of|it|in|for)\b/,
                           splits_text_on:     /[\s\/\-\,\&]+/,
                           normalizes_words:   [[/Deoxyribonucleic Acid/i, 'DNA']],
                           
                           substitutes_characters_with: CharacterSubstituters::WestEuropean.new,
                           maximum_tokens: 5
          
          books_index = index :books,
                              Sources::DB.new('SELECT id, title, author, isbn13 as isbn FROM books', :file => 'app/db.yml')
          books_index.define_category :title,
                                      similarity: Similarity::DoubleLevenshtone.new(3) # Up to three similar title word indexed.
          books_index.define_category :author
          books_index.define_category :isbn,
                                      partial: Partial::None.new # Partially searching on an ISBN makes not much sense.
          
          geo_index = index :geo, Sources::CSV.new(:location, :north, :east, file: 'data/ch.csv', col_sep: ',')
          geo_index.define_category :location
          geo_index.define_ranged_category(:north1, 1, precision: 3, from: :north)
                   .define_ranged_category(:east1,  1, precision: 3, from: :east)
          
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