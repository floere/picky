# encoding: utf-8
#
class BookSearch < Application
    
    default_indexing removes_characters:                 /[',\(\)#:!@;\?]/,
                     contracts_expressions:              [/mr\.\s*|mister\s*/i, 'mr '],
                     stopwords:                          /\b(und|and|the|or|on|of|in|is|to|from|as|at|an)\b/,
                     splits_text_on:                     /[\s\/\-\"\&\.]/,
                     removes_characters_after_splitting: /[\.]/,
                     normalizes_words:                   [[/\$(\w+)/i, '\1 dollars']],
                     
                     substitutes_characters_with:        CharacterSubstitution::European.new
    
    default_querying removes_characters:                 /[\(\)\']/,
                     contracts_expressions:              [/mr\.\s*|mister\s*/i, 'mr '],
                     stopwords:                          /\b(und|and|the|or|on|of|in|is|to|from|as|at|an)\b/,
                     splits_text_on:                     /[\s\/\-\,\&]+/,
                     removes_characters_after_splitting: /[\.]/,
                     
                     maximum_tokens:                     5,
                     substitutes_characters_with:        CharacterSubstitution::European.new
                     
                     
    similar_title = category :title,  :qualifiers => [:t, :title, :titre],
                                   :partial => Partial::Substring.new(:from => 1),
                                   :similarity =>  Similarity::DoubleLevenshtone.new(2)
    author        = category :author, :qualifiers => [:a, :author, :auteur],
                                   :partial => Partial::Substring.new(:from => -2)
    year          = category :year,   :qualifiers => [:y, :year, :annee]
    isbn          = category :isbn,   :qualifiers => [:i, :isbn]
    
    main_index = index :main,
                       Sources::DB.new('SELECT id, title, author, year FROM books', :file => 'app/db.yml'),
                       similar_title,
                       author,
                       year
    
    isbn_index = index :isbn,
                       Sources::DB.new("SELECT id, isbn FROM books", :file => 'app/db.yml'),
                       field(:isbn, :qualifiers => [:i, :isbn])
    
    csv_test_index = index :csv_test,
                           Sources::CSV.new(:title,:author,:isbn,:year,:publisher,:subjects, :file => 'data/books.csv'),
                           similar_title,
                           author,
                           isbn,
                           year,
                           category(:publisher, :qualifiers => [:p, :publisher]),
                           category(:subjects, :qualifiers => [:s, :subject])
                           
    
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
    
    full_isbn = Query::Full.new isbn_index, options
    live_isbn = Query::Live.new isbn_index, options
    
    route %r{^/books/full} => full_main,
          %r{^/books/live} => live_main,
          %r{^/csv/full}   => full_csv,
          %r{^/csv/live}   => live_csv,
          %r{^/isbn/full}  => full_isbn,
          %r{^/all/full}   => Query::Full.new(main_index, csv_test_index, isbn_index, options),
          %r{^/all/live}   => Query::Live.new(main_index, csv_test_index, isbn_index, options)
    
    root 200
    
end