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

class BookSearch < Sinatra::Application

  include Picky

  extend Picky::Sinatra

  indexing substitutes_characters_with: CharacterSubstituters::WestEuropean.new,
           removes_characters:          /[^äöüa-zA-Z0-9\s\/\-\_\:\"\&\|]/i,
           stopwords:                   /\b(and|the|or|on|of|in|is|to|from|as|at|an)\b/i,
           splits_text_on:              /[\s\/\-\_\:\"\&\/]/,
           normalizes_words:            [[/\$(\w+)/i, '\1 dollars']],
           rejects_token_if:            lambda { |token| token.blank? || token == 'Amistad' },
           case_sensitive:              false

  searching substitutes_characters_with: CharacterSubstituters::WestEuropean.new,
            removes_characters:          /[^ïôåñëäöüa-zA-Z0-9\s\/\-\_\,\&\.\"\~\*\:]/i,
            stopwords:                   /\b(and|the|or|on|of|in|is|to|from|as|at|an)\b/i,
            splits_text_on:              /[\s\/\&\/]/,
            case_sensitive:              true,
            max_words:                   5
  
  def self.map url, things
    self.get %r{\A/#{url}\z} do
      things.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
    end
  end
  
  weights = {
    [:author]         => +6,
    [:title, :author] => +5,
    [:author, :year]  => +2
  }

  map 'books', Search.new(BooksIndex, ISBNIndex) {
    boost weights
  }
  map 'books_ignoring', Search.new(BooksIndex, ISBNIndex) {
    boost weights
    ignore_unassigned_tokens true
  }
  map 'book_each', Search.new(BookEachIndex) {
    boost weights
    # ignore :title
  }
  map 'redis', Search.new(RedisIndex) {
    boost weights
  }
  map 'memory_changing', Search.new(MemoryChangingIndex)
  map 'redis_changing', Search.new(RedisChangingIndex)
  map 'csv', Search.new(CSVTestIndex) {
    boost weights
  }  
  map 'isbn', Search.new(ISBNIndex)
  map 'sym', Search.new(SymKeysIndex)
  map 'geo', Search.new(RealGeoIndex)
  map 'simple_geo', Search.new(MgeoIndex)
  map 'iphone', Search.new(IphoneLocations)
  map 'indexing', Search.new(IndexingIndex)
  map 'file', Search.new(FileIndex)
  map 'japanese', Search.new(JapaneseIndex) {
    searching removes_characters: /[^\p{Han}\p{Katakana}\p{Hiragana}\"\~\*\:\,]/i, # a-zA-Z0-9\s\/\-\_\&\.
              stopwords:          /\b(and|the|of|it|in|for)\b/i,
              splits_text_on:     /[\s\/\-\&]+/
  }
  map 'nonstring', Search.new(NonstringDataIndex)
  map 'partial', Search.new(PartialIndex)
  # map 'sqlite', Search.new(SQLiteIndex) # TODO Fix, reinstate.
  map 'all', Search.new(BooksIndex, CSVTestIndex, ISBNIndex, MgeoIndex) {
    boost weights
  }

  # Live.
  #
  live = Picky::Interfaces::LiveParameters::Unicorn.new
  get %r{\A/admin\z} do
    results = live.parameters params
    results.to_json
  end

end