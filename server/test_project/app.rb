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

Picky.logger = Picky::Loggers::Verbose.new

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

  weights = {
    [:author]         => +6,
    [:title, :author] => +5,
    [:author, :year]  => +2
  }

  # This looks horrible – but usually you have it only once or twice.
  # It's more flexible.
  #
  require 'logger'
  AppLogger = Logger.new File.expand_path('log/search.log', Picky.root)
  books_search = Search.new BooksIndex, ISBNIndex do boost weights end
  get %r{\A/books\z} do
    results = books_search.search params[:query], params[:ids] || 20, params[:offset] || 0
    AppLogger.info results
    results.to_json
  end
  books_ignoring_search = Search.new BooksIndex, ISBNIndex do
                             boost weights
                             ignore_unassigned_tokens true
                          end
  get %r{\A/books_ignoring\z} do
    books_ignoring_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  book_each_search = Search.new BookEachIndex do
                       boost weights
                       # ignore :title
                     end
  get %r{\A/book_each\z} do
    book_each_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  redis_search = Search.new RedisIndex do boost weights end
  get %r{\A/redis\z} do
    redis_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  memory_changing_search = Search.new MemoryChangingIndex
  get %r{\A/memory_changing\z} do
    memory_changing_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  redis_changing_search = Search.new RedisChangingIndex
  get %r{\A/redis_changing\z} do
    redis_changing_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  csv_test_search = Search.new CSVTestIndex do boost weights end
  get %r{\A/csv\z} do
    csv_test_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  isbn_search = Search.new ISBNIndex
  get %r{\A/isbn\z} do
    isbn_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  sym_keys_search = Search.new SymKeysIndex
  get %r{\A/sym\z} do
    sym_keys_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  real_geo_search = Search.new RealGeoIndex
  get %r{\A/geo\z} do
    real_geo_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  mgeo_search = Search.new MgeoIndex
  get %r{\A/simple_geo\z} do
    mgeo_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  iphone_search = Search.new IphoneLocations
  get %r{\A/iphone\z} do
    iphone_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  indexing_search = Search.new IndexingIndex
  get %r{\A/indexing\z} do
    indexing_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  file_search = Search.new FileIndex
  get %r{\A/file\z} do
    file_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  japanese_search = Search.new JapaneseIndex do
    searching removes_characters: /[^\p{Han}\p{Katakana}\p{Hiragana}\"\~\*\:\,]/i, # a-zA-Z0-9\s\/\-\_\&\.
              stopwords:          /\b(and|the|of|it|in|for)\b/i,
              splits_text_on:     /[\s\/\-\&]+/
  end
  get %r{\A/japanese\z} do
    japanese_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  nonstring_search = Search.new NonstringDataIndex
  get %r{\A/nonstring\z} do
    nonstring_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  partial_search = Search.new PartialIndex
  get %r{\A/partial\z} do
    partial_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  # sqlite_search = Search.new sqlite_index
  # get %r{\A/sqlite\z} do
  #   sqlite_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  # end
  all_search = Search.new BooksIndex, CSVTestIndex, ISBNIndex, MgeoIndex do boost weights end
  get %r{\A/all\z} do
    all_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end

  # Live.
  #
  live = Picky::Interfaces::LiveParameters::Unicorn.new
  get %r{\A/admin\z} do
    results = live.parameters params
    results.to_json
  end

end