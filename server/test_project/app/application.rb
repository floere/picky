# encoding: utf-8
#
class BookSearch < Application
    
    indexing.removes_characters(/[',\(\)#:!@;\?]/)
    indexing.contracts_expressions(/mr\.\s*|mister\s*/i, 'mr ')
    indexing.stopwords(/\b(and|the|or|on|of|in|is|to|from|as|at|an)\b/)
    indexing.splits_text_on(/[\s\/\-\"\&\.]/)
    indexing.removes_characters_after_splitting(/[\.]/)
    
    few_similarities = Similarity::DoubleLevenshtone.new(2)
    similar_title = field :title,  :qualifiers => [:t, :title, :titre],
                                   :similarity => few_similarities
    author        = field :author, :qualifiers => [:a, :author, :auteur], :partial => Partial::Subtoken.new(:down_to => -2)
    year          = field :year,   :qualifiers => [:y, :year, :annee]
    isbn          = field :isbn,   :qualifiers => [:i, :isbn]
    
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
                           field(:publisher, :qualifiers => [:p, :publisher]),
                           field(:subjects, :qualifiers => [:s, :subject])
                           
    # TODO Should these be definable per Query?
    #      And serve only as defaults if the query cannot find them?
    #
    querying.maximum_tokens 5
    querying.removes_characters(/[\(\)\']/)
    querying.contracts_expressions(/mr\.\s*|mister\s*/i, 'mr')
    querying.stopwords(/\b(and|the|or|on)/i)
    querying.splits_text_on(/[\s\/\-\,\&]+/) #
    querying.normalizes_words([
      [/Deoxyribonucleic Acid/i, 'DNA']
    ])
    querying.removes_characters_after_splitting(/[\.]/)
    
    options = { :weights => Query::Weights.new([:author] => 6, [:title, :author] => 5, [:author, :year] => 2) }
    
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
          %r{^/all/full}   => Query::Full.new(main_index, csv_test_index, isbn_index),
          %r{^/all/live}   => Query::Live.new(main_index, csv_test_index, isbn_index)
    
    root 200
  
end