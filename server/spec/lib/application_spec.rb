# encoding: utf-8
#
require 'spec_helper'

describe Picky::Application do
  
  describe "integration" do
    it "should run ok" do
      lambda {
        class MinimalTestApplication < described_class
          books = Picky::Indexes::Memory.new :books,
                                             source: Picky::Sources::DB.new(
                                               'SELECT id, title FROM books',
                                               :file => 'app/db.yml'
                                             )
          books.define_category :title
          
          rack_adapter.stub! :exclaim # Stopping it from exclaiming.
          
          route %r{^/books} => Picky::Search.new(books)
        end
        Picky::Tokenizers::Index.default.tokenize 'some text'
        Picky::Tokenizers::Query.default.tokenize 'some text'
      }.should_not raise_error
    end
    it "should run ok" do
      lambda {
        # Here we just test if the API can be called ok.
        #
        class TestApplication < described_class
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
                    
                    substitutes_characters_with: Picky::CharacterSubstituters::WestEuropean.new,
                    maximum_tokens: 5
          
          books_index = Picky::Indexes::Memory.new :books,
                                                   source: Picky::Sources::DB.new(
                                                     'SELECT id, title, author, isbn13 as isbn FROM books',
                                                     :file => 'app/db.yml'
                                                   )
          books_index.define_category :title,
                                      similarity: Picky::Similarity::DoubleMetaphone.new(3) # Up to three similar title word indexed.
          books_index.define_category :author,
                                      similarity: Picky::Similarity::Soundex.new(2)
          books_index.define_category :isbn,
                                      partial: Picky::Partial::None.new # Partially searching on an ISBN makes not much sense.
          
          geo_index = Picky::Indexes::Memory.new :geo do
            source          Picky::Sources::CSV.new(:location, :north, :east, file: 'data/ch.csv', col_sep: ',')
            indexing        removes_characters: /[^a-z]/
            category        :location,
                            similarity: Picky::Similarity::Metaphone.new(4)
            ranged_category :north1, 1, precision: 3, from: :north
            ranged_category :east1,  1, precision: 3, from: :east
          end
          
          rack_adapter.stub! :exclaim # Stopping it from exclaiming.
          
          route %r{^/books} => Picky::Search.new(books_index)
          
          buks_search = Picky::Search.new(books_index) do
            searching removes_characters: /[buks]/
          end
          route %r{^/buks} => buks_search
        end
      }.should_not raise_error
    end
  end
  
  describe 'finalize' do
    before(:each) do
      described_class.stub! :check
    end
    it 'checks if all is ok' do
      described_class.should_receive(:check).once.with
      
      described_class.finalize
    end
    it 'tells the rack adapter to finalize' do
      described_class.rack_adapter.should_receive(:finalize).once.with
      
      described_class.finalize
    end
  end
  
  describe 'check' do
    it 'does something' do
      described_class.should_receive(:warn).once.with "\nWARNING: No routes defined for application configuration in Class.\n\n"
      
      described_class.check
    end
  end
  
  describe 'delegation' do
    it "should delegate route" do
      described_class.rack_adapter.should_receive(:route).once.with :path => :query
      
      described_class.route :path => :query
    end
  end
  
  describe 'rack_adapter' do
    it 'should be there' do
      lambda { described_class.rack_adapter }.should_not raise_error
    end
    it "should return a new FrontendAdapters::Rack instance" do
      described_class.rack_adapter.should be_kind_of(Picky::FrontendAdapters::Rack)
    end
    it "should cache the instance" do
      described_class.rack_adapter.should == described_class.rack_adapter
    end
  end
  
  describe 'route' do
    it 'is delegated' do
      described_class.rack_adapter.should_receive(:route).once.with :some_options
      
      described_class.route(:some_options)
    end
    it 'raises on block' do
      expect {
        described_class.route :quack => Hash.new do # Anything with a block.
          # do something
        end
      }.to raise_error("Warning: block passed into #route method, not into Search.new!")
    end
  end
  
  describe 'call' do
    before(:each) do
      @routes = stub :routes
      described_class.stub! :rack_adapter => @routes
    end
    it 'should delegate' do
      @routes.should_receive(:call).once.with :env
      
      described_class.call :env
    end
  end
  
end