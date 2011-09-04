# encoding: utf-8
#
require File.expand_path '../logging', __FILE__

class ChangingItem

  attr_reader :id, :name

  def initialize id, name
    @id, @name = id, name
  end

end

class BookSearch < Picky::Application

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

    books_index = Picky::Index.new :books do
      source   Picky::Sources::DB.new('SELECT id, title, author, year FROM books', file: 'app/db.yml')
      category :id
      category :title,
               qualifiers: [:t, :title, :titre],
               partial:    Picky::Partial::Substring.new(:from => 1),
               similarity: Picky::Similarity::DoubleMetaphone.new(2)
      category :author, partial: Picky::Partial::Substring.new(:from => -2)
      category :year, qualifiers: [:y, :year, :annee]
      result_identifier 'boooookies'
    end

    class Book < ActiveRecord::Base; end
    Book.establish_connection YAML.load(File.open('app/db.yml'))
    book_each_index = Picky::Index.new :book_each do
      key_format :to_s
      source     Book.order('title ASC')
      category   :id
      category   :title,
                 qualifiers: [:t, :title, :titre],
                 partial:    Picky::Partial::Substring.new(:from => 1),
                 similarity: Picky::Similarity::DoubleMetaphone.new(2)
      category   :author, partial: Picky::Partial::Substring.new(:from => -2)
      category   :year, qualifiers: [:y, :year, :annee]
    end

    isbn_index = Picky::Index.new :isbn do
      source   Picky::Sources::DB.new("SELECT id, isbn FROM books", :file => 'app/db.yml')
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

    rss_index = Picky::Index.new :rss do
      source     EachRSSItemProxy.new
      key_format :to_s

      category   :title
      # etc...
    end

    # Breaking example to test the nice error message.
    #
    # breaking = Index.new :isbn, Sources::DB.new("SELECT id, isbn FROM books", :file => 'app/db.yml') do
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
    isbn_each_index = Picky::Index.new :isbn_each do
      source   [ISBN.new('ABC'), ISBN.new('DEF')]
      category :isbn, :qualifiers => [:i, :isbn], :key_format => :to_s
    end

    mgeo_index = Picky::Index.new :memory_geo do
      source          Picky::Sources::CSV.new(:location, :north, :east, file: 'data/ch.csv', col_sep: ',')
      category        :location
      ranged_category :north1, 0.008, precision: 3, from: :north
      ranged_category :east1,  0.008, precision: 3, from: :east
    end

    real_geo_index = Picky::Index.new :real_geo do
      source         Picky::Sources::CSV.new(:location, :north, :east, file: 'data/ch.csv', col_sep: ',')
      category       :location, partial: Picky::Partial::Substring.new(from: 1)
      geo_categories :north, :east, 1, precision: 3
    end

    iphone_locations = Picky::Index.new :iphone do
      source Picky::Sources::CSV.new(
        :mcc,
        :mnc,
        :lac,
        :ci,
        :timestamp,
        :latitude,
        :longitude,
        :horizontal_accuracy,
        :altitude,
        :vertical_accuracy,
        :speed,
        :course,
        :confidence,
        file: 'data/iphone_locations.csv'
      )
      ranged_category :timestamp, 86_400, precision: 5, qualifiers: [:ts, :timestamp]
      geo_categories  :latitude, :longitude, 25, precision: 3
    end

    Picky::Index.new :underscore_regression do
      source         Picky::Sources::CSV.new(:location, file: 'data/ch.csv')
      category       :some_place, :from => :location
    end

    # rgeo_index = Index.new :redis_geo, Sources::CSV.new(:location, :north, :east, file: 'data/ch.csv', col_sep: ',')
    # rgeo_index.define_category :location
    # rgeo_index.define_map_location(:north1, 1, precision: 3, from: :north)
    #           .define_map_location(:east1,  1, precision: 3, from: :east)

    csv_test_index = Picky::Index.new(:csv_test) do
      source Picky::Sources::CSV.new(:title,:author,:isbn,:year,:publisher,:subjects, file: 'data/books.csv')

      category :title,
                qualifiers: [:t, :title, :titre],
                partial:    Picky::Partial::Substring.new(from: 1),
                similarity: Picky::Similarity::DoubleMetaphone.new(2)
      category  :author,
                qualifiers: [:a, :author, :auteur],
                partial:    Picky::Partial::Substring.new(from: -2)
      category  :year,
                qualifiers: [:y, :year, :annee],
                partial:    Picky::Partial::None.new
      category  :publisher, qualifiers: [:p, :publisher]
      category  :subjects, qualifiers: [:s, :subject]

      result_identifier :Books
    end

    indexing_index = Picky::Index.new(:special_indexing) do
      source   Picky::Sources::CSV.new(:title, file: 'data/books.csv')
      indexing removes_characters: /[^äöüd-zD-Z0-9\s\/\-\"\&\.]/i, # a-c, A-C are removed
               splits_text_on:     /[\s\/\-\"\&\/]/
      category :title,
               qualifiers: [:t, :title, :titre],
               partial:    Picky::Partial::Substring.new(from: 1),
               similarity: Picky::Similarity::DoubleMetaphone.new(2)
    end

   redis_index = Picky::Index.new(:redis) do
     backend  Picky::Backends::Redis.new
     source   Picky::Sources::CSV.new(:title, :author, :isbn, :year, :publisher, :subjects, file: 'data/books.csv')
     category :title,
              qualifiers: [:t, :title, :titre],
              partial:    Picky::Partial::Substring.new(from: 1),
              similarity: Picky::Similarity::DoubleMetaphone.new(2)
     category :author,
              qualifiers: [:a, :author, :auteur],
              partial:    Picky::Partial::Substring.new(from: -2)
     category :year,
              qualifiers: [:y, :year, :annee],
              partial:    Picky::Partial::None.new
     category :publisher, qualifiers: [:p, :publisher]
     category :subjects,  qualifiers: [:s, :subject]
   end

    sym_keys_index = Picky::Index.new :symbol_keys do
      source   Picky::Sources::CSV.new(:text, file: "data/#{PICKY_ENVIRONMENT}/symbol_keys.csv", key_format: 'strip')
      category :text, partial: Picky::Partial::Substring.new(from: 1)
    end

    memory_changing_index = Picky::Index.new(:memory_changing) do
      source [
        ChangingItem.new("1", 'first entry'),
        ChangingItem.new("2", 'second entry'),
        ChangingItem.new("3", 'third entry')
      ]
      category :name
    end

    redis_changing_index = Picky::Index.new(:redis_changing) do
      backend  Picky::Backends::Redis.new
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

    japanese_index = Picky::Index.new(:japanese) do
      source Picky::Sources::CSV.new(:japanese, :german, :file => "data/japanese.tab", :col_sep => "\t")

      indexing :removes_characters => /[^\p{Han}\p{Katakana}\p{Hiragana}\s;]/,
               :stopwords =>         /\b(and|the|of|it|in|for)\b/i,
               :splits_text_on =>    /[\s;]/

      category :japanese,
               :partial => Picky::Partial::Substring.new(from: 1)
    end

    weights = {
      [:author]         => +6,
      [:title, :author] => +5,
      [:author, :year]  => +2
    }

    route %r{\A/admin\Z}           => Picky::LiveParameters.new

    route %r{\A/books\Z}           => (Picky::Search.new(books_index, isbn_index) do boost weights end),
          %r{\A/books_ignoring\Z}  => (Picky::Search.new(books_index, isbn_index) do
                                         boost weights
                                         ignore_unassigned_tokens true
                                      end),
          %r{\A/book_each\Z}       => (Picky::Search.new(book_each_index) do
                                         boost weights
                                         ignore :title
                                       end),
          %r{\A/redis\Z}           => (Picky::Search.new(redis_index) do boost weights end),
          %r{\A/memory_changing\Z} => Picky::Search.new(memory_changing_index),
          %r{\A/redis_changing\Z}  => Picky::Search.new(redis_changing_index),
          %r{\A/csv\Z}             => (Picky::Search.new(csv_test_index) do boost weights end),
          %r{\A/isbn\Z}            => Picky::Search.new(isbn_index),
          %r{\A/sym\Z}             => Picky::Search.new(sym_keys_index),
          %r{\A/geo\Z}             => Picky::Search.new(real_geo_index),
          %r{\A/simple_geo\Z}      => Picky::Search.new(mgeo_index),
          %r{\A/iphone\Z}          => Picky::Search.new(iphone_locations),
          %r{\A/indexing\Z}        => Picky::Search.new(indexing_index),
          %r{\A/file\Z}            => Picky::Search.new(file_index)
    japanese_search = Picky::Search.new(japanese_index) do
      searching removes_characters: /[^\p{Han}\p{Katakana}\p{Hiragana}\"\~\*\:\,]/i, # a-zA-Z0-9\s\/\-\_\&\.
                stopwords:          /\b(and|the|of|it|in|for)\b/i,
                splits_text_on:     /[\s\/\-\&]+/
    end
    route %r{\A/japanese\Z}        => japanese_search
    route %r{\A/all\Z}             => (Picky::Search.new(books_index, csv_test_index, isbn_index, mgeo_index) do boost weights end)

end

previous_handler = Signal.trap('USR1') { Picky::Indexes.reload; previous_handler.call }