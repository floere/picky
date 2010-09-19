# encoding: utf-8
#
class BookSearch < Application
  
  queries do
    maximum_tokens 5
    illegal(/[\(\)\']/)
    contract(/mr\.\s*|mister\s*/i, 'mr')
    stopwords(/\b(and|the|or|on)/i)
    split_on(/[\s\/\-\,\&]+/)
    normalizing_word_patterns([
      [/Deoxyribonucleic Acid/i, 'DNA']
    ])
    illegal_after_normalizing(/[\.]/)
    
    route '^/books/full', Query::Full.new(Indexes[:main], Indexes[:isbn])
    route '^/books/live', Query::Live.new(Indexes[:main], Indexes[:isbn])
    
    route '^/isbn/full',  Query::Full.new(Indexes[:isbn])
    
    root 200
  end
  
  indexes :partial => Cacher::Partial::Subtoken.new, :similarity => Cacher::Similarity::None.new do
    
    illegal(/[',\(\)#:!@]/)
    contract(/mr\.\s*|mister\s*/i, 'mr')
    stopwords(/\b(and|the|or|on)\b/)
    split_on(/[\s\/\-\"\&\.]/)
    illegal_after_normalizing(/[\.]/)
    
    few_similarities = Similarity::DoubleLevenshtone.new(3)
    similar_title = field :title,  :similarity => few_similarities,
                                   :qualifiers => [:t, :title, :titre]
    author        = field :author, :qualifiers => [:a, :author, :auteur]
    year          = field :year,   :partial    => Partial::None.new,
                                   :qualifiers => [:y, :year, :annee]
    index :main,
          "SELECT title, author, year FROM books",
          similar_title,
          author,
          year,
          :heuristics => Query::Heuristics.new([:title,  :author] => 5,
                                               [:author, :year]   => 2)
    
    index :isbn,
          "SELECT isbn FROM books",
          field(:isbn, :qualifiers => [:i, :isbn])
  end
end