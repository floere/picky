# encoding: utf-8
#
class BookSearch < Application

    indexing removes_characters:                 /[^äöüa-zA-Z0-9\s\/\-\"\&\.]/i,
             stopwords:                          /\b(and|the|or|on|of|in|is|to|from|as|at|an)\b/i,
             splits_text_on:                     /[\s\/\-\"\&\/]/,
             removes_characters_after_splitting: /[\.]/,
             normalizes_words:                   [[/\$(\w+)/i, '\1 dollars']],
             rejects_token_if:                   lambda { |token| token.blank? || token == :amistad },
             case_sensitive:                     false,

             substitutes_characters_with:        CharacterSubstituters::WestEuropean.new

    querying removes_characters:                 /[^ïôåñëäöüa-zA-Z0-9\s\/\-\,\&\.\"\~\*\:]/i,
             stopwords:                          /\b(and|the|or|on|of|in|is|to|from|as|at|an)\b/i,
             splits_text_on:                     /[\s\/\-\,\&\/]/,
             removes_characters_after_splitting: //,
             # rejects_token_if:                   lambda { |token| token.blank? || token == :hell }, # Not yet.
             case_sensitive:                     true,

             maximum_tokens:                     5,
             substitutes_characters_with:        CharacterSubstituters::WestEuropean.new

    books_index = Index::Memory.new :books, result_identifier: 'boooookies' do
      source   Sources::DB.new('SELECT id, title, author, year FROM books', file: 'app/db.yml')
      category :id
      category :title,
               qualifiers: [:t, :title, :titre],
               partial:    Partial::Substring.new(:from => 1),
               similarity: Similarity::DoubleMetaphone.new(2)
      category :author, partial: Partial::Substring.new(:from => -2)
      category :year, qualifiers: [:y, :year, :annee]
    end

    class Book < ActiveRecord::Base; end
    Book.establish_connection YAML.load(File.open('app/db.yml'))
    book_each_index = Index::Memory.new :book_each do
      source   Book.order('title ASC')
      category :id
      category :title,
               qualifiers: [:t, :title, :titre],
               partial:    Partial::Substring.new(:from => 1),
               similarity: Similarity::DoubleMetaphone.new(2)
      category :author, partial: Partial::Substring.new(:from => -2)
      category :year, qualifiers: [:y, :year, :annee]
    end

    isbn_index = Index::Memory.new :isbn do
      source   Sources::DB.new("SELECT id, isbn FROM books", :file => 'app/db.yml')
      category :isbn, :qualifiers => [:i, :isbn]
    end

    # Breaking example to test the nice error message.
    #
    # breaking = Index::Memory.new :isbn, Sources::DB.new("SELECT id, isbn FROM books", :file => 'app/db.yml') do
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
    isbn_each_index = Index::Memory.new :isbn_each, source: [ISBN.new('ABC'), ISBN.new('DEF')] do
      category :isbn, :qualifiers => [:i, :isbn]
    end

    mgeo_index = Index::Memory.new :memory_geo do
      source          Sources::CSV.new(:location, :north, :east, file: 'data/ch.csv', col_sep: ',')
      category        :location
      ranged_category :north1, 0.008, precision: 3, from: :north
      ranged_category :east1,  0.008, precision: 3, from: :east
    end

    real_geo_index = Index::Memory.new :real_geo do
      source         Sources::CSV.new(:location, :north, :east, file: 'data/ch.csv', col_sep: ',')
      category       :location
      geo_categories :north, :east, 1, precision: 3
    end

    # rgeo_index = Index::Redis.new :redis_geo, Sources::CSV.new(:location, :north, :east, file: 'data/ch.csv', col_sep: ',')
    # rgeo_index.define_category :location
    # rgeo_index.define_map_location(:north1, 1, precision: 3, from: :north)
    #           .define_map_location(:east1,  1, precision: 3, from: :east)

    csv_test_index = Index::Memory.new(:csv_test, result_identifier: 'Books') do
      source   Sources::CSV.new(:title,:author,:isbn,:year,:publisher,:subjects, file: 'data/books.csv')
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
    end

    Index::Memory.new(:special_indexing) do
      source   Sources::CSV.new(:title, file: 'data/books.csv')
      indexing removes_characters: /[^äöüd-zD-Z0-9\s\/\-\"\&\.]/i, # a-c, A-C are removed
               splits_text_on:     /[\s\/\-\"\&\/]/
      category :title,
               qualifiers: [:t, :title, :titre],
               partial:    Partial::Substring.new(from: 1),
               similarity: Similarity::DoubleMetaphone.new(2)
    end

   redis_index = Index::Redis.new(:redis) do
     source   Sources::CSV.new(:title,:author,:isbn,:year,:publisher,:subjects, file: 'data/books.csv')
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

    sym_keys_index = Index::Memory.new :symbol_keys do
      source   Sources::CSV.new(:text, file: 'data/symbol_keys.csv', key_format: 'strip')
      category :text, partial: Partial::Substring.new(from: 1)
    end

    options = {
      :weights => {
        [:author]         => 6,
        [:title, :author] => 5,
        [:author, :year]  => 2
      }
    }

    route %r{\A/admin\Z}      => LiveParameters.new

    route %r{\A/books\Z}      => Search.new(books_index, isbn_index, options),
          %r{\A/redis\Z}      => Search.new(redis_index, options),
          %r{\A/csv\Z}        => Search.new(csv_test_index, options),
          %r{\A/isbn\Z}       => Search.new(isbn_index),
          %r{\A/geo\Z}        => Search.new(real_geo_index),
          %r{\A/simple_geo\Z} => Search.new(mgeo_index),
          %r{\A/all\Z}        => Search.new(books_index, csv_test_index, isbn_index, mgeo_index, options)

    root 200

end

previous_handler = Signal.trap('USR1') { }
Signal.trap('USR1') { Indexes.reload; previous_handler.call }