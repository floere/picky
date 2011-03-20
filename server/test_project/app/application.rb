# encoding: utf-8
#
class BookSearch < Application

    default_indexing removes_characters:                 /[^äöüa-zA-Z0-9\s\/\-\"\&\.]/,
                     stopwords:                          /\b(und|and|the|or|on|of|in|is|to|from|as|at|an)\b/,
                     splits_text_on:                     /[\s\/\-\"\&]/,
                     removes_characters_after_splitting: /[\.]/,
                     normalizes_words:                   [[/\$(\w+)/i, '\1 dollars']],
                     reject_token_if:                    lambda { |token| token.blank? || token == :amistad },

                     substitutes_characters_with:        CharacterSubstituters::WestEuropean.new

    default_querying removes_characters:                 /[^ïôåñëäöüa-zA-Z0-9\s\/\-\,\&\.\"\~\*\:]/,
                     stopwords:                          /\b(und|and|the|or|on|of|in|is|to|from|as|at|an)\b/,
                     splits_text_on:                     /[\s\/\-\,\&]+/,
                     removes_characters_after_splitting: //,

                     maximum_tokens:                     5,
                     substitutes_characters_with:        CharacterSubstituters::WestEuropean.new

    books_index = Index::Memory.new :books, Sources::DB.new('SELECT id, title, author, year FROM books', file: 'app/db.yml'), result_identifier: 'boooookies' do
      category :id
      category :title,
               qualifiers: [:t, :title, :titre],
               partial:    Partial::Substring.new(:from => 1),
               similarity: Similarity::Phonetic.new(2)
      category :author, partial: Partial::Substring.new(:from => -2)
      category :year, qualifiers: [:y, :year, :annee]
    end

    isbn_index = Index::Memory.new :isbn, Sources::DB.new("SELECT id, isbn FROM books", :file => 'app/db.yml') do
      category :isbn, :qualifiers => [:i, :isbn]
    end

    mgeo_index = Index::Memory.new :memory_geo, Sources::CSV.new(:location, :north, :east, file: 'data/ch.csv', col_sep: ',') do
      category     :location
      map_location :north1, 1, precision: 3, from: :north
      map_location :east1,  1, precision: 3, from: :east
    end

    # rgeo_index  = Index::Redis.new :redis_geo, Sources::CSV.new(:location, :north, :east, file: 'data/ch.csv', col_sep: ',')
    # rgeo_index.define_category :location
    # rgeo_index.define_map_location(:north1, 1, precision: 3, from: :north)
    #           .define_map_location(:east1,  1, precision: 3, from: :east)

    csv_test_index = Index::Memory.new(:csv_test, Sources::CSV.new(:title,:author,:isbn,:year,:publisher,:subjects, file: 'data/books.csv'), result_identifier: 'Books') do
      category :title,
               qualifiers: [:t, :title, :titre],
               partial:    Partial::Substring.new(from: 1),
               similarity: Similarity::Phonetic.new(2)
      category :author,
               qualifiers: [:a, :author, :auteur],
               partial:    Partial::Substring.new(from: -2)
      category :year,
               qualifiers: [:y, :year, :annee],
               partial:    Partial::None.new
      category :publisher, qualifiers: [:p, :publisher]
      category :subjects, qualifiers: [:s, :subject]
    end

   redis_index = Index::Redis.new(:redis, Sources::CSV.new(:title,:author,:isbn,:year,:publisher,:subjects, file: 'data/books.csv')) do
     category :title,
               qualifiers: [:t, :title, :titre],
               partial:    Partial::Substring.new(from: 1),
               similarity: Similarity::Phonetic.new(2)
     category :author,
               qualifiers: [:a, :author, :auteur],
               partial:    Partial::Substring.new(from: -2)
     category :year,
               qualifiers: [:y, :year, :annee],
               partial:    Partial::None.new
     category :publisher, qualifiers: [:p, :publisher]
     category :subjects,  qualifiers: [:s, :subject]
   end

    sym_keys_index = Index::Memory.new :symbol_keys, Sources::CSV.new(:text, file: 'data/symbol_keys.csv', key_format: 'strip') do
      category :text, partial: Partial::Substring.new(from: 1)
    end

    options = {
      :weights => {
        [:author]         => 6,
        [:title, :author] => 5,
        [:author, :year]  => 2
      }
    }

    route %r{\A/admin\Z} => LiveParameters.new

    route %r{\A/books\Z} => Search.new(books_index, isbn_index, options),
          %r{\A/redis\Z} => Search.new(redis_index, options),
          %r{\A/csv\Z}   => Search.new(csv_test_index, options),
          %r{\A/isbn\Z}  => Search.new(isbn_index),
          %r{\A/geo\Z}   => Search.new(mgeo_index),
          %r{\A/all\Z}   => Search.new(books_index, csv_test_index, isbn_index, mgeo_index, options)

    root 200

end

previous_handler = Signal.trap('USR1') { }
Signal.trap('USR1') { Indexes.reload; previous_handler.call }