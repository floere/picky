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
require File.expand_path '../../lib/picky', __FILE__

ChangingItem = Struct.new :id, :name

Picky.logger = Picky::Loggers::Concise.new

class BookSearch < Sinatra::Application

  include Picky

  extend Picky::Sinatra

  indexing substitutes_characters_with: Picky::CharacterSubstituters::WestEuropean.new,
           removes_characters:          /[^äöüa-zA-Z0-9\s\/\-\_\:\"\&\|]/i,
           stopwords:                   /\b(and|the|or|on|of|in|is|to|from|as|at|an)\b/i,
           splits_text_on:              /[\s\/\-\_\:\"\&\/]/,
           normalizes_words:            [[/\$(\w+)/i, '\1 dollars']],
           rejects_token_if:            lambda { |token| token.blank? || token == 'Amistad' },
           case_sensitive:              false

  searching substitutes_characters_with: Picky::CharacterSubstituters::WestEuropean.new,
            removes_characters:          /[^ïôåñëäöüa-zA-Z0-9\s\/\-\_\,\&\.\"\~\*\:]/i,
            stopwords:                   /\b(and|the|or|on|of|in|is|to|from|as|at|an)\b/i,
            splits_text_on:              /[\s\/\&\/]/,
            case_sensitive:              true,
            max_words:                   5
  
  require_relative 'models/each'
  
  require_relative 'indexes/books'
  require_relative 'indexes/book_each'
  require_relative 'indexes/isbn'
  require_relative 'indexes/rss'
  require_relative 'indexes/isbn_each'
  
  require_relative 'indexes/mgeo'
  require_relative 'indexes/real_geo'
  require_relative 'indexes/iphone_locations'

  require_relative 'indexes/underscore_regression'

  require_relative 'indexes/csv_test'

  require_relative 'indexes/indexing'

  require_relative 'indexes/redis'
  
  require_relative 'indexes/sym_keys'
  
  require_relative 'indexes/memory_changing'
  require_relative 'indexes/redis_changing'
  require_relative 'indexes/file'
  
  require_relative 'indexes/japanese'
  
  require_relative 'indexes/nonstring_data'
  require_relative 'indexes/partial'
  require_relative 'indexes/weights'

  # SQLiteItem = Struct.new :id, :first_name, :last_name
  # sqlite_index = Picky::Index.new :sqlite do
  #   backend Backends::SQLite.new
  #   source do
  #     [
  #       SQLiteItem.new(1, "hello", "sqlite"),
  #       SQLiteItem.new(2, "bingo", "bongo")
  #     ]
  #   end
  #   category :first_name
  #   category :last_name
  # end

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

  books_search = Search.new BooksIndex, ISBNIndex do boost weights end
  map 'books', books_search
  
  books_ignoring = Search.new(BooksIndex, ISBNIndex) do
                     boost weights
                     ignore_unassigned_tokens true
                   end
  map 'books_ignoring', books_ignoring
  
  book_each = Search.new(BookEachIndex) do
                boost weights
                # ignore :title
              end
  map 'book_each', book_each
  
  map 'redis', Search.new(RedisIndex) { boost weights }
  map 'memory_changing', Search.new(MemoryChangingIndex)
  map 'redis_changing', Search.new(RedisChangingIndex)
  map 'csv', Search.new(CSVTestIndex) { boost weights }  
  map 'isbn', Search.new(ISBNIndex)
  map 'sym', Search.new(SymKeysIndex)
  map 'geo', Search.new(RealGeoIndex)
  map 'simple_geo', Search.new(MgeoIndex)
  map 'iphone', Search.new(IphoneLocations)
  map 'indexing', Search.new(IndexingIndex)
  map 'file', Search.new(FileIndex)
  
  japanese_search = Search.new JapaneseIndex do
    searching removes_characters: /[^\p{Han}\p{Katakana}\p{Hiragana}\"\~\*\:\,]/i, # a-zA-Z0-9\s\/\-\_\&\.
              stopwords:          /\b(and|the|of|it|in|for)\b/i,
              splits_text_on:     /[\s\/\-\&]+/
  end
  map 'japanese', japanese_search
  
  map 'nonstring', Search.new(NonstringDataIndex)
  map 'partial', Search.new(PartialIndex)  
  # map 'sqlite', Search.new(SQLiteIndex)
  
  all_search = Search.new BooksIndex, CSVTestIndex, ISBNIndex, MgeoIndex do boost weights end
  map 'all', all_search

  # Live.
  #
  live = Picky::Interfaces::LiveParameters::Unicorn.new
  get %r{\A/admin\z} do
    results = live.parameters params
    results.to_json
  end

end