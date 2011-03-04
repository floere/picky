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
    
    main_index = Index::Memory.new :main, Sources::DB.new('SELECT id, title, author, year FROM books', file: 'app/db.yml')
    main_index.define_category :id
    main_index.define_category :title,
                               qualifiers: [:t, :title, :titre],
                               partial:    Partial::Substring.new(:from => 1),
                               similarity: Similarity::Phonetic.new(2)
    main_index.define_category :author,
                               partial:    Partial::Substring.new(:from => -2)
    main_index.define_category :year,
                               qualifiers: [:y, :year, :annee]
    
    isbn_index = Index::Memory.new :isbn, Sources::DB.new("SELECT id, isbn FROM books", :file => 'app/db.yml')
    isbn_index.define_category :isbn, :qualifiers => [:i, :isbn]
    
    mgeo_index  = Index::Memory.new :memory_geo, Sources::CSV.new(:location, :north, :east, file: 'data/ch.csv', col_sep: ',')
    mgeo_index.define_category :location
    mgeo_index.define_map_location(:north1, 1, precision: 3, from: :north)
              .define_map_location(:east1,  1, precision: 3, from: :east)
    
    # rgeo_index  = API::Index::Redis.new :redis_geo, Sources::CSV.new(:location, :north, :east, file: 'data/ch.csv', col_sep: ',')
    # rgeo_index.define_category :location
    # rgeo_index.define_map_location(:north1, 1, precision: 3, from: :north)
    #           .define_map_location(:east1,  1, precision: 3, from: :east)
    
    csv_test_index = Index::Memory.new(:csv_test, Sources::CSV.new(:title,:author,:isbn,:year,:publisher,:subjects, file: 'data/books.csv'))
                       .define_category(:title,
                                         qualifiers: [:t, :title, :titre],
                                         partial:    Partial::Substring.new(from: 1),
                                         similarity: Similarity::Phonetic.new(2))
                       .define_category(:author,
                                         qualifiers: [:a, :author, :auteur],
                                         partial:    Partial::Substring.new(from: -2))
                       .define_category(:year,
                                         qualifiers: [:y, :year, :annee],
                                         partial:    Partial::None.new)
                       .define_category(:publisher, qualifiers: [:p, :publisher])
                       .define_category(:subjects, qualifiers: [:s, :subject])
    
   redis_index = Index::Redis.new(:redis, Sources::CSV.new(:title,:author,:isbn,:year,:publisher,:subjects, file: 'data/books.csv'))
                   .define_category(:title,
                                     qualifiers: [:t, :title, :titre],
                                     partial:    Partial::Substring.new(from: 1),
                                     similarity: Similarity::Phonetic.new(2))
                   .define_category(:author,
                                     qualifiers: [:a, :author, :auteur],
                                     partial:    Partial::Substring.new(from: -2))
                   .define_category(:year,
                                     qualifiers: [:y, :year, :annee],
                                     partial:    Partial::None.new)
                   .define_category(:publisher, qualifiers: [:p, :publisher])
                   .define_category(:subjects, qualifiers: [:s, :subject])
    
    sym_keys_index  = Index::Memory.new :symbol_keys, Sources::CSV.new(:text, file: 'data/symbol_keys.csv', key_format: 'strip')
    sym_keys_index.define_category :text, partial: Partial::Substring.new(from: 1)
    
    options = {
      :weights => {
        [:author]         => 6,
        [:title, :author] => 5,
        [:author, :year]  => 2
      }
    }
    
    full_main = Query::Full.new main_index, isbn_index, options
    live_main = Query::Live.new main_index, isbn_index, options
    
    full_csv  = Query::Full.new csv_test_index, options
    live_csv  = Query::Live.new csv_test_index, options
    
    full_isbn = Query::Full.new isbn_index
    live_isbn = Query::Live.new isbn_index
    
    full_mgeo  = Query::Full.new mgeo_index
    live_mgeo  = Query::Live.new mgeo_index
    
    route %r{\A/admin\Z}      => LiveParameters.new
    
    route %r{\A/books/full\Z} => full_main,
          %r{\A/books/live\Z} => live_main,

          %r{\A/redis/full\Z} => Query::Full.new(redis_index, options),
          %r{\A/redis/live\Z} => Query::Live.new(redis_index, options),
          
          %r{\A/csv/full\Z}   => full_csv,
          %r{\A/csv/live\Z}   => live_csv,
          
          %r{\A/isbn/full\Z}  => full_isbn,
          
          %r{\A/geo/full\Z}   => full_mgeo,
          %r{\A/geo/live\Z}   => live_mgeo,
          
          %r{\A/all/full\Z}   => Query::Full.new(main_index, csv_test_index, isbn_index, mgeo_index, options),
          %r{\A/all/live\Z}   => Query::Live.new(main_index, csv_test_index, isbn_index, mgeo_index, options)
    
    root 200
    
end

previous_handler = Signal.trap('USR1') { }
Signal.trap('USR1') { Indexes.reload; previous_handler.call }