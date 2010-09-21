# encoding: utf-8
#
class BookSearch < Application
  
  indexes do
    # defaults :partial => Cacher::Partial::Subtoken.new, :similarity => Cacher::Similarity::None.new
    
    illegal_characters(/[',\(\)#:!@]/)
    contract_expressions(/mr\.\s*|mister\s*/i, 'mr')
    stopwords(/\b(and|the|or|on)\b/)
    split_text_on(/[\s\/\-\"\&\.]/)
    illegal_characters_after(/[\.]/)
    
    few_similarities = Similarity::DoubleLevenshtone.new(3)
    similar_title = field :title,  :similarity => few_similarities,
                                   :qualifiers => [:t, :title, :titre]
    author        = field :author, :qualifiers => [:a, :author, :auteur]
    year          = field :year,   :partial    => Partial::None.new,
                                   :qualifiers => [:y, :year, :annee]
    type :main,
          Sources::DB.new('SELECT title, author, year FROM books', DB::Source),
          similar_title,
          author,
          year,
          :heuristics => Query::Heuristics.new([:title,  :author] => 5,
                                               [:author, :year]   => 2)
    
    type :isbn,
          "SELECT isbn FROM books",
          field(:isbn, :qualifiers => [:i, :isbn])
  end
  
  queries do
    maximum_tokens 5
    illegal_characters(/[\(\)\']/)
    contract_expressions(/mr\.\s*|mister\s*/i, 'mr')
    stopwords(/\b(and|the|or|on)/i)
    split_text_on(/[\s\/\-\,\&]+/)
    normalize_words([
      [/Deoxyribonucleic Acid/i, 'DNA']
    ])
    illegal_characters_after(/[\.]/)
    
    route '^/books/full', Query::Full.new(Indexes[:main], Indexes[:isbn]) # full_query_with(:main, :isbn)
    route '^/books/live', Query::Live.new(Indexes[:main], Indexes[:isbn]) # live_query_with(:main, :isbn)
    
    route '^/isbn/full',  Query::Full.new(Indexes[:isbn])                 # full_query_with(:isbn)
    
    root 200
  end
  
end