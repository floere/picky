# encoding: utf-8
#

# 1. Index using rake index
# 2. Start with rake start
# 3. curl '127.0.0.1:8080/all?query=bla'
#

# Stresstest using
#   ab -kc 5 -t 5 http://127.0.0.1:4567/csv?query=t
#

require 'sinatra/base'
require 'active_record'
require 'csv'
require File.expand_path '../../lib/picky', __FILE__ # Use the current state of Picky.

require_relative 'models'
require_relative 'indexes'
require_relative 'logging'
require_relative 'defaults'

class BookSearch < Sinatra::Application
  
  def self.map url, things
    self.get %r{\A/#{url}\z} do
      things.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
    end
  end
  
  def self.install_routes
    weights = {
      [:author]         => +6,
      [:title, :author] => +5,
      [:author, :year]  => +2
    }

    map 'books', Picky::Search.new(BooksIndex, ISBNIndex) {
      boost weights
    }
    map 'books_ignoring', Picky::Search.new(BooksIndex, ISBNIndex) {
      boost weights
      ignore_unassigned_tokens true
    }
    map 'book_each', Picky::Search.new(BookEachIndex) {
      boost weights
      # ignore :title
    }
    map 'redis', Picky::Search.new(RedisIndex) {
      boost weights
    }
    map 'memory_changing', Picky::Search.new(MemoryChangingIndex)
    map 'redis_changing', Picky::Search.new(RedisChangingIndex)
    map 'csv', Picky::Search.new(CSVTestIndex) {
      boost weights
    }  
    map 'isbn', Picky::Search.new(ISBNIndex)
    map 'sym', Picky::Search.new(SymKeysIndex)
    map 'geo', Picky::Search.new(RealGeoIndex)
    map 'simple_geo', Picky::Search.new(MgeoIndex)
    map 'iphone', Picky::Search.new(IphoneLocations)
    map 'indexing', Picky::Search.new(IndexingIndex)
    map 'file', Picky::Search.new(FileIndex)
    map 'japanese', Picky::Search.new(JapaneseIndex) {
      searching removes_characters: /[^\p{Han}\p{Katakana}\p{Hiragana}\"\~\*\:\,]/i, # a-zA-Z0-9\s\/\-\_\&\.
                stopwords:          /\b(and|the|of|it|in|for)\b/i,
                splits_text_on:     /[\s\/\-\&]+/
    }
    map 'nonstring', Picky::Search.new(NonstringDataIndex)
    map 'partial', Picky::Search.new(PartialIndex)
    # map 'sqlite', Picky::Search.new(SQLiteIndex) # TODO Fix, reinstate.
    map 'commas', Picky::Search.new(CommaIdsIndex)
    map 'all', Picky::Search.new(BooksIndex, CSVTestIndex, ISBNIndex, MgeoIndex) {
      boost weights
    }
  end

  # Live.
  #
  live = Picky::Interfaces::LiveParameters::Unicorn.new
  get %r{\A/admin\z} do
    results = live.parameters params
    results.to_json
  end

end

BookSearch.install_routes