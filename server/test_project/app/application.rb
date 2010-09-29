# encoding: utf-8
#
class BookSearch < Application
  
  indexes do
    # defaults :partial => Cacher::Partial::Subtoken.new, :similarity => Cacher::Similarity::None.new
    
    illegal_characters(/[',\(\)#:!@]/)
    contract_expressions(/mr\.\s*|mister\s*/i, 'mr ')
    stopwords(/\b(and|the|or|on)\b/)
    split_text_on(/[\s\/\-\"\&\.]/)
    illegal_characters_after(/[\.]/)
    
    few_similarities = Similarity::DoubleLevenshtone.new(3)
    similar_title = field :title,  :similarity => few_similarities,
                                   :qualifiers => [:t, :title, :titre]
    author        = field :author, :qualifiers => [:a, :author, :auteur]
    year          = field :year,   :partial    => Partial::None.new,
                                   :qualifiers => [:y, :year, :annee]
    
    
    adapter = DB.configure :file => 'config/db/source.yml'
    
    type :main,
          Sources::DB.new('SELECT id, title, author, year FROM books', adapter),
          similar_title,
          author,
          year,
          :heuristics => Query::Heuristics.new([:author] => 6,
                                               [:title,  :author] => 5,
                                               [:author, :year]   => 2)
    
    type :isbn,
          Sources::DB.new("SELECT id, isbn FROM books", adapter),
          field(:isbn, :qualifiers => [:i, :isbn])
  end
  
  queries do
    # TODO Should these be definable per Query?
    #      And serve only as defaults if the query cannot find them?
    #
    maximum_tokens 5
    illegal_characters(/[\(\)\']/)
    contract_expressions(/mr\.\s*|mister\s*/i, 'mr')
    stopwords(/\b(and|the|or|on)/i)
    split_text_on(/[\s\/\-\,\&]+/) #
    normalize_words([
      [/Deoxyribonucleic Acid/i, 'DNA'] # normalize_tokens
    ])
    illegal_characters_after(/[\.]/) # illegal_after
    
    # TODO Make regexps. Or allow also Strings?
    route %r{^/books/full}, Query::Full.new(Indexes[:main], Indexes[:isbn]) # full_query_with(:main, :isbn)
    route %r{^/books/live}, Query::Live.new(Indexes[:main], Indexes[:isbn]) # live_query_with(:main, :isbn)
    
    route %r{^/isbn/full},  Query::Full.new(Indexes[:isbn])                 # full_query_with(:isbn)
    
    root 200
  end
  
end