# encoding: utf-8
#

# Stresstest using
#   ab -kc 5 -t 5 http://127.0.0.1:4567/csv?query=t
#

require 'sinatra/base'
require 'active_record'
require 'csv'
require File.expand_path '../../lib/picky', __FILE__

class ChangingItem

  attr_reader :id, :name

  def initialize id, name
    @id, @name = id, name
  end

end

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
            maximum_tokens:              5

  require_relative 'models/book'

  books_index = Index.new :books do
    source   { Book.all }
    category :id
    category :title,
             qualifiers: [:t, :title, :titre],
             partial:    Partial::Substring.new(:from => 1),
             similarity: Similarity::DoubleMetaphone.new(2)
    category :author, partial: Partial::Substring.new(:from => -2)
    category :year, qualifiers: [:y, :year, :annee]

    result_identifier 'boooookies'
  end

  book_each_index = Index.new :book_each do
    key_format :to_s
    source     { Book.order('title ASC') }
    category   :id
    category   :title,
               qualifiers: [:t, :title, :titre],
               partial:    Partial::Substring.new(:from => 1),
               similarity: Similarity::DoubleMetaphone.new(2)
    category   :author, partial: Partial::Substring.new(:from => -2)
    category   :year, qualifiers: [:y, :year, :annee]
  end

  isbn_index = Index.new :isbn do
    source { Book.all }
    category :isbn, :qualifiers => [:i, :isbn]
  end

  class EachRSSItemProxy

    def each &block
      require 'rss'
      require 'open-uri'
      rss_feed = "http://florianhanke.com/blog/atom.xml"
      rss_content = ""
      open rss_feed do |f|
         rss_content = f.read
      end
      rss = RSS::Parser.parse rss_content, true
      rss.items.each &block
    rescue
      # Don't call block, no data.
    end

  end

  rss_index = Index.new :rss do
    source     EachRSSItemProxy.new
    key_format :to_s

    category   :title
    # etc...
  end

  # Breaking example to test the nice error message.
  #
  # breaking = Index.new :isbn, Sources::DB.new("SELECT id, isbn FROM books", :file => 'db.yml') do
  #   category :isbn, :qualifiers => [:i, :isbn]
  # end

  # Fake ISBN class to demonstrate that #each indexing is working.
  #
  class ISBN
    @@id = 1
    attr_reader :id, :isbn
    def initialize isbn
      @id   = @@id += 1
      @isbn = isbn
    end
  end
  isbn_each_index = Index.new :isbn_each do
    source   [ISBN.new('ABC'), ISBN.new('DEF')]
    category :isbn, :qualifiers => [:i, :isbn], :key_format => :to_s
  end

  require_relative 'models/each'

  require_relative 'models/swiss_locations'
  mgeo_index = Index.new :memory_geo do
    source          { SwissLocations.all('data/ch.csv', col_sep: ",") }
    category        :location
    ranged_category :north1, 0.008, precision: 3, from: :north
    ranged_category :east1,  0.008, precision: 3, from: :east
  end
  real_geo_index = Index.new :real_geo do
    source         { SwissLocations.all('data/ch.csv', col_sep: ",") }
    category       :location, partial: Partial::Substring.new(from: 1)
    geo_categories :north, :east, 1, precision: 3
  end

  require_relative 'models/iphone_data'
  iphone_locations = Index.new :iphone do
    source { IphoneData.all('data/iphone_locations.csv') }
    ranged_category :timestamp, 86_400, precision: 5, qualifiers: [:ts, :timestamp]
    geo_categories  :latitude, :longitude, 25, precision: 3
  end

  Index.new :underscore_regression do
    source   { SwissLocations.all('data/ch.csv', col_sep: ",") }
    category :some_place, :from => :location
  end

  require_relative 'models/csv_book'
  csv_test_index = Index.new :csv_test do
    source   { CSVBook.all('data/books.csv') }

    category :title,
             qualifiers: [:t, :title, :titre],
             partial:    Partial::Substring.new(from: 1),
             similarity: Similarity::DoubleMetaphone.new(2)
    category :author,
             qualifiers: [:a, :author, :auteur],
             partial:    Partial::Substring.new(from: -2)
    category :year,
             qualifiers: [:y, :year, :annee],
             partial:    Partial::None.new
    category :publisher, qualifiers: [:p, :publisher]
    category :subjects, qualifiers: [:s, :subject]

    result_identifier :Books
  end

  indexing_index = Index.new(:special_indexing) do
    source   { CSVBook.all('data/books.csv') }
    indexing removes_characters: /[^äöüd-zD-Z0-9\s\/\-\"\&\.]/i, # a-c, A-C are removed
             splits_text_on:     /[\s\/\-\"\&\/]/
    category :title,
             qualifiers: [:t, :title, :titre],
             partial:    Partial::Substring.new(from: 1),
             similarity: Similarity::DoubleMetaphone.new(2)
  end

  redis_index = Index.new(:redis) do
    backend  Backends::Redis.new
    source   { CSVBook.all('data/books.csv') }
    category :title,
             qualifiers: [:t, :title, :titre],
             partial:    Partial::Substring.new(from: 1),
             similarity: Similarity::DoubleMetaphone.new(2)
    category :author,
             qualifiers: [:a, :author, :auteur],
             partial:    Partial::Substring.new(from: -2)
    category :year,
             qualifiers: [:y, :year, :annee],
             partial:    Partial::None.new
    category :publisher, qualifiers: [:p, :publisher]
    category :subjects,  qualifiers: [:s, :subject]
  end

  require_relative 'models/symbol_keys'
  sym_keys_index = Index.new :symbol_keys do
    key_format :strip
    source   { SymbolKeys.all("data/#{PICKY_ENVIRONMENT}/symbol_keys.csv") }
    category :text, partial: Partial::Substring.new(from: 1)
  end

  memory_changing_index = Index.new(:memory_changing) do
    source [
      ChangingItem.new("1", 'first entry'),
      ChangingItem.new("2", 'second entry'),
      ChangingItem.new("3", 'third entry')
    ]
    category :name
  end

  redis_changing_index = Index.new(:redis_changing) do
    backend Backends::Redis.new
    source [
      ChangingItem.new("1", 'first entry'),
      ChangingItem.new("2", 'second entry'),
      ChangingItem.new("3", 'third entry')
    ]
    category :name
  end

  file_index = Picky::Index.new(:file) do
    backend  Picky::Backends::File.new
    source [
      ChangingItem.new("1", 'first entry'),
      ChangingItem.new("2", 'second entry'),
      ChangingItem.new("3", 'third entry')
    ]
    category :name,
             partial: Picky::Partial::Infix.new(min: -3)
  end

  require_relative 'models/japanese'
  japanese_index = Picky::Index.new(:japanese) do
    source   { Japanese.all('data/japanese.tab', col_sep: "\t") }

    indexing :removes_characters => /[^\p{Han}\p{Katakana}\p{Hiragana}\s;]/,
             :stopwords =>         /\b(and|the|of|it|in|for)\b/i,
             :splits_text_on =>    /[\s;]/

    category :japanese,
             :partial => Picky::Partial::Substring.new(from: 1)
  end

  BackendModel = Struct.new :id, :name

  # # To test the interface definition.
  # #
  # class InternalBackendInterfaceTester
  #
  #   def initialize
  #     @hash = {}
  #   end
  #
  #   def [] key
  #     @hash[key]
  #   end
  #
  #   def []= key, value
  #     @hash[key] = value
  #   end
  #
  #   # We need to implement this as we use it
  #   # in a Memory::JSON backend.
  #   #
  #   def to_json
  #     @hash.to_json
  #   end
  #
  # end
  #
  # backends_index = Picky::Index.new(:backends) do
  #   source  [
  #     BackendModel.new(1, "Memory"),
  #     BackendModel.new(2, "Redis")
  #   ]
  #   backend Picky::Backends::Memory.new(
  #             inverted: ->(bundle) do
  #               Picky::Backends::Memory::JSON.new(bundle.index_path(:inverted))
  #             end,
  #             weights: Picky::Backends::Memory::JSON.new(
  #               "#{PICKY_ROOT}/index/#{PICKY_ENVIRONMENT}/funky_weights_path",
  #               empty: InternalBackendInterfaceTester.new,
  #               initial: InternalBackendInterfaceTester.new
  #             )
  #           )
  #   category :name
  # end

  # This checks that we can use a funky customized tokenizer.
  #
  NonStringDataSource = Struct.new :id, :nonstring
  class NonStringTokenizer < Picky::Tokenizer
    def tokenize nonstring
      [nonstring.map(&:to_sym)]
    end
  end
  nonstring_data_index = Picky::Index.new(:nonstring) do
    source {
      [
        NonStringDataSource.new(1, ['gaga', :blabla, 'haha']),
        NonStringDataSource.new(2, [:meow, 'moo', :bang, 'zap'])
      ]
    }
    indexing NonStringTokenizer.new
    category :nonstring
  end

  PartialItem = Struct.new :id, :substring, :postfix, :infix, :none
  partial_index = Picky::Index.new(:partial) do
    source do
      [
        PartialItem.new(1, "octopussy", "octopussy", "octopussy", "octopussy"),
        PartialItem.new(2, "abracadabra", "abracadabra", "abracadabra", "abracadabra")
      ]
    end
    category :substring, partial: Picky::Partial::Substring.new(from: -5, to: -3)
    category :postfix, partial: Picky::Partial::Postfix.new(from: -5)
    category :infix, partial: Picky::Partial::Infix.new
    category :none, partial: Picky::Partial::None.new
  end

  # This just tests indexing.
  #
  WeightsItem = Struct.new :id, :logarithmic, :constant_default, :constant, :dynamic
  Picky::Index.new(:weights) do
    source do
      [
        WeightsItem.new(1, "octopussy", "octopussy", "octopussy", "octopussy"),
        WeightsItem.new(2, "abracadabra", "abracadabra", "abracadabra", "abracadabra")
      ]
    end
    category :logarithmic,      weight: Picky::Weights::Logarithmic.new
    category :constant_default, weight: Picky::Weights::Constant.new
    category :constant,         weight: Picky::Weights::Constant.new(3.14)
    category :dynamic,          weight: Picky::Weights::Dynamic.new { |token| token.size }
  end

  SQLiteItem = Struct.new :id, :first_name, :last_name
  sqlite_index = Picky::Index.new :sqlite do
    backend Backends::SQLite.new
    source do
      [
        SQLiteItem.new(1, "hello", "sqlite"),
        SQLiteItem.new(2, "bingo", "bongo")
      ]
    end
    category :first_name
    category :last_name
  end

  weights = {
    [:author]         => +6,
    [:title, :author] => +5,
    [:author, :year]  => +2
  }

  # This looks horrible – but usually you have it only once or twice.
  # It's flexible.
  #
  books_search = Search.new books_index, isbn_index do boost weights end
  get %r{\A/books\z} do
    books_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  books_ignoring_search = Search.new books_index, isbn_index do
                             boost weights
                             ignore_unassigned_tokens true
                          end
  get %r{\A/books_ignoring\z} do
    books_ignoring_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  book_each_search = Search.new book_each_index do
                       boost weights
                       ignore :title
                     end
  get %r{\A/book_each\z} do
    book_each_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  redis_search = Search.new redis_index do boost weights end
  get %r{\A/redis\z} do
    redis_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  memory_changing_search = Search.new memory_changing_index
  get %r{\A/memory_changing\z} do
    memory_changing_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  redis_changing_search = Search.new redis_changing_index
  get %r{\A/redis_changing\z} do
    redis_changing_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  csv_test_search = Search.new csv_test_index do boost weights end
  get %r{\A/csv\z} do
    csv_test_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  isbn_search = Search.new isbn_index
  get %r{\A/isbn\z} do
    isbn_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  sym_keys_search = Search.new sym_keys_index
  get %r{\A/sym\z} do
    sym_keys_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  real_geo_search = Search.new real_geo_index
  get %r{\A/geo\z} do
    real_geo_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  mgeo_search = Search.new mgeo_index
  get %r{\A/simple_geo\z} do
    mgeo_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  iphone_search = Search.new iphone_locations
  get %r{\A/iphone\z} do
    iphone_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  indexing_search = Search.new indexing_index
  get %r{\A/indexing\z} do
    indexing_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  file_search = Search.new file_index
  get %r{\A/file\z} do
    file_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  japanese_search = Search.new japanese_index do
    searching removes_characters: /[^\p{Han}\p{Katakana}\p{Hiragana}\"\~\*\:\,]/i, # a-zA-Z0-9\s\/\-\_\&\.
              stopwords:          /\b(and|the|of|it|in|for)\b/i,
              splits_text_on:     /[\s\/\-\&]+/
  end
  get %r{\A/japanese\z} do
    japanese_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  # backends_search = Search.new backends_index do
  #   searching case_sensitive: false
  # end
  # get %r{\A/backends\z} do
  #   backends_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  # end
  nonstring_search = Search.new nonstring_data_index
  get %r{\A/nonstring\z} do
    nonstring_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  partial_search = Search.new partial_index
  get %r{\A/partial\z} do
    partial_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  sqlite_search = Search.new sqlite_index
  get %r{\A/sqlite\z} do
    sqlite_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end
  all_search = Search.new books_index, csv_test_index, isbn_index, mgeo_index do boost weights end
  get %r{\A/all\z} do
    all_search.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
  end

end