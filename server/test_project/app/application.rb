# encoding: utf-8
#
class BookSearch < Application
    
    default_indexing removes_characters:                 /[^a-zA-Z0-9\s\/\-\"\&\.]/,
                     stopwords:                          /\b(und|and|the|or|on|of|in|is|to|from|as|at|an)\b/,
                     splits_text_on:                     /[\s\/\-\"\&\.]/,
                     removes_characters_after_splitting: /[\.]/,
                     normalizes_words:                   [[/\$(\w+)/i, '\1 dollars']],
                     
                     substitutes_characters_with:        CharacterSubstituters::WestEuropean.new
    
    default_querying removes_characters:                 /[^ïôåñëa-zA-Z0-9\s\/\-\,\&\"\~\*\:]/,
                     stopwords:                          /\b(und|and|the|or|on|of|in|is|to|from|as|at|an)\b/,
                     splits_text_on:                     /[\s\/\-\,\&]+/,
                     removes_characters_after_splitting: /[\.]/,
                     
                     maximum_tokens:                     5,
                     substitutes_characters_with:        CharacterSubstituters::WestEuropean.new
    
    main_index = index :main, Sources::DB.new('SELECT id, title, author, year FROM books', :file => 'app/db.yml')
    main_index.define_category :title,
                               qualifiers: [:t, :title, :titre],
                               partial:    Partial::Substring.new(:from => 1),
                               similarity: Similarity::Phonetic.new(2)
    main_index.define_category :author,
                               partial:    Partial::Substring.new(:from => -2)
    main_index.define_category :year,
                               qualifiers: [:y, :year, :annee]
    
    isbn_index = index :isbn, Sources::DB.new("SELECT id, isbn FROM books", :file => 'app/db.yml')
    isbn_index.define_category :isbn, :qualifiers => [:i, :isbn]
    
    geo_index  = index :geo, Sources::CSV.new(:location, :north, :east, :file => 'data/locations.csv')
    geo_index.define_category :location
    geo_index.define_location :north, grid: 2
    # geo_index.location :east,  grid: 2
    # geo_index.location :north, grid: 2 # TODO partial does not make sense!
    # geo_index.location :east,  grid: 2
    # geo_location(:north, grid: 20_000, :as => :n20k),
    # geo_location(:east, grid: 20_000, :as => :e20k)
    
    csv_test_index = index(:csv_test, Sources::CSV.new(:title,:author,:isbn,:year,:publisher,:subjects, :file => 'data/books.csv'))
                       .define_category(:title,
                                 qualifiers: [:t, :title, :titre],
                                 partial:    Partial::Substring.new(:from => 1),
                                 similarity: Similarity::Phonetic.new(2))
                       .define_category(:author,
                                 qualifiers: [:a, :author, :auteur],
                                 partial:    Partial::Substring.new(:from => -2))
                       .define_category(:year,
                                 qualifiers: [:y, :year, :annee])
                       .define_category(:publisher, :qualifiers => [:p, :publisher])
                       .define_category(:subjects, :qualifiers => [:s, :subject])
    
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
    
    full_geo  = Query::Full.new geo_index
    live_geo  = Query::Live.new geo_index
    
    route %r{\A/books/full\Z} => full_main,
          %r{\A/books/live\Z} => live_main,
          
          %r{\A/csv/full\Z}   => full_csv,
          %r{\A/csv/live\Z}   => live_csv,
          
          %r{\A/isbn/full\Z}  => full_isbn,
          
          %r{\A/geo/full\Z}   => full_geo,
          %r{\A/geo/live\Z}   => live_geo,
          
          %r{\A/all/full\Z}   => Query::Full.new(main_index, csv_test_index, isbn_index, geo_index, options),
          %r{\A/all/live\Z}   => Query::Live.new(main_index, csv_test_index, isbn_index, geo_index, options)
    
    root 200
    
end