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

require_relative 'project'

class BookSearch < Sinatra::Application
  
  def self.routes
    weights = {
      [:author]         => +6,
      [:title, :author] => +5,
      [:author, :year]  => +2
    }
    
    {
      books: Picky::Search.new(BooksIndex, ISBNIndex) {
        boost weights
      },
      books_ignoring: Picky::Search.new(BooksIndex, ISBNIndex) {
        boost weights
        ignore_unassigned_tokens true
      },
      book_each: Picky::Search.new(BookEachIndex) {
        boost weights
        # ignore :title
      },
      redis: Picky::Search.new(RedisIndex) {
        boost weights
      },
      memory_changing: Picky::Search.new(MemoryChangingIndex),
      redis_changing: Picky::Search.new(RedisChangingIndex),
      csv: Picky::Search.new(CSVTestIndex) {
        boost weights
      },
      isbn: Picky::Search.new(ISBNIndex),
      sym: Picky::Search.new(SymKeysIndex),
      geo: Picky::Search.new(RealGeoIndex),
      simple_geo: Picky::Search.new(MgeoIndex),
      iphone: Picky::Search.new(IphoneLocations),
      indexing: Picky::Search.new(IndexingIndex),
      file: Picky::Search.new(FileIndex),
      japanese: Picky::Search.new(JapaneseIndex) {
        searching removes_characters: /[^\p{Han}\p{Katakana}\p{Hiragana}\"\~\*\:\,]/i, # a-zA-Z0-9\s\/\-\_\&\.
                  stopwords:          /\b(and|the|of|it|in|for)\b/i,
                  splits_text_on:     /[\s\/\-\&]+/
      },
      nonstring: Picky::Search.new(NonstringDataIndex),
      partial: Picky::Search.new(PartialIndex),
      # sqlite: Picky::Search.new(SQLiteIndex), # TODO Fix, reinstate.
      commas: Picky::Search.new(CommaIdsIndex),
      all: Picky::Search.new(BooksIndex, CSVTestIndex, ISBNIndex, MgeoIndex) {
        boost weights
      }
    }
  end
  
  routes.each do |(path, things)|
    get %r{\A/#{path}\z} do
      things.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
    end
  end

  # Live.
  #
  live = Picky::Interfaces::LiveParameters::Unicorn.new
  get %r{\A/admin\z} do
    results = live.parameters params
    results.to_json
  end

end