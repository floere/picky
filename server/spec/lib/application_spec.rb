# encoding: utf-8
#
require 'spec_helper'

describe Application do
  
  describe "integration" do
    it "should run ok" do
      lambda {
        class MinimalTestApplication < Application
          books = Index::Memory.new :books, source: Sources::DB.new('SELECT id, title FROM books', :file => 'app/db.yml')
          books.define_category :title
          
          rack_adapter.stub! :exclaim # Stopping it from exclaiming.
          
          route %r{^/books} => Search.new(books)
        end
        Internals::Tokenizers::Index.default.tokenize 'some text'
        Internals::Tokenizers::Query.default.tokenize 'some text'
      }.should_not raise_error
    end
    it "should run ok" do
      lambda {
        # Here we just test if the API can be called ok.
        #
        class TestApplication < Application
          indexing  removes_characters:                 /[^a-zA-Z0-9\s\/\-\"\&\.]/,
                    stopwords:                          /\b(and|the|of|it|in|for)\b/,
                    splits_text_on:                     /[\s\/\-\"\&\.]/,
                    removes_characters_after_splitting: /[\.]/,
                    normalizes_words:                   [[/\$(\w+)/i, '\1 dollars']],
                    rejects_token_if:                   lambda { |token| token.blank? || token == :amistad }
                           
          searching removes_characters: /[^a-zA-Z0-9äöü\s\/\-\,\&\"\~\*\:]/,
                    stopwords:          /\b(and|the|of|it|in|for)\b/,
                    splits_text_on:     /[\s\/\-\,\&]+/,
                    normalizes_words:   [[/Deoxyribonucleic Acid/i, 'DNA']],
                    
                    substitutes_characters_with: CharacterSubstituters::WestEuropean.new,
                    maximum_tokens: 5 # TODO maximum_words?
          
          books_index = Index::Memory.new :books,
                                          source: Sources::DB.new('SELECT id, title, author, isbn13 as isbn FROM books', :file => 'app/db.yml')
          books_index.define_category :title,
                                      similarity: Similarity::DoubleMetaphone.new(3) # Up to three similar title word indexed.
          books_index.define_category :author,
                                      similarity: Similarity::Soundex.new(2)
          books_index.define_category :isbn,
                                      partial: Partial::None.new # Partially searching on an ISBN makes not much sense.
          
          geo_index = Index::Memory.new :geo do
            source          Sources::CSV.new(:location, :north, :east, file: 'data/ch.csv', col_sep: ',')
            indexing        removes_characters: /[^a-z]/
            category        :location,
                            similarity: Similarity::Metaphone.new(4)
            ranged_category :north1, 1, precision: 3, from: :north
            ranged_category :east1,  1, precision: 3, from: :east
          end
          
          rack_adapter.stub! :exclaim # Stopping it from exclaiming.
          
          route %r{^/books} => Search.new(books_index)
          route %r{^/buks}  => Search.new(books_index) do
            searching removes_characters: /[buks]/
          end
        end
      }.should_not raise_error
    end
  end
  
  describe 'finalize' do
    before(:each) do
      Application.stub! :check
    end
    it 'checks if all is ok' do
      Application.should_receive(:check).once.with
      
      Application.finalize
    end
    it 'tells the rack adapter to finalize' do
      Application.rack_adapter.should_receive(:finalize).once.with
      
      Application.finalize
    end
  end
  
  describe 'check' do
    it 'does something' do
      Application.should_receive(:warn).once.with "\nWARNING: No routes defined for application configuration in Class.\n\n"
      
      Application.check
    end
  end
  
  describe 'delegation' do
    it "should delegate route" do
      Application.rack_adapter.should_receive(:route).once.with :path => :query
      
      Application.route :path => :query
    end
  end
  
  describe 'rack_adapter' do
    it 'should be there' do
      lambda { Application.rack_adapter }.should_not raise_error
    end
    it "should return a new FrontendAdapters::Rack instance" do
      Application.rack_adapter.should be_kind_of(Internals::FrontendAdapters::Rack)
    end
    it "should cache the instance" do
      Application.rack_adapter.should == Application.rack_adapter
    end
  end
  
  describe 'call' do
    before(:each) do
      @routes = stub :routes
      Application.stub! :rack_adapter => @routes
    end
    it 'should delegate' do
      @routes.should_receive(:call).once.with :env
      
      Application.call :env
    end
  end
  
end