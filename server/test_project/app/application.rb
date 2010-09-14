# coding: utf-8
#
class BookSearch < Application
  
  # Part 1: Defaults.
  #
  # Sets defaults in the options object.
  #
  # Methods:
  #  * partial:
  #    * Cacher::Partial::None.new     # Doesn't generate a partial index.
  #    * Cacher::Partial::Subtoken.new # Default. Generates a partial index.
  #  * similarity:
  #    * Cacher::Similarity::None.new
  #    * 
  #
  defaults do
    partial    Cacher::Partial::Subtoken.new
    similarity Cacher::Similarity::None.new
  end
  
  routing do
    route '^/books/full', Query::Full.new(Indexes[:main], Indexes[:isbn])
    route '^/books/live', Query::Live.new(Indexes[:main], Indexes[:isbn])
    
    route '^/isbn/full',  Query::Full.new(Indexes[:isbn])
    
    root 200 # Heartbeat check by web front server.
  end
  
  indexing do
    illegal(/[',\(\)#:!@]/)
    illegal_after_normalizing(/[\.]/)
    stopwords(/\b(and|the|or|on)\b/)
    split_on(/[\s\/\-\"\&\.]/)
  end
  
  querying do
    maximum_tokens 5
    
    illegal(/[()']/)
    stopwords(/\b(and|the|or|on)/i)
    contract(/mr\.\s*|mister\s*/i, 'mr')
    split_on(/[\s\/\-\,\&]+/)
    normalizing_word_patterns([
      [/^Deoxyribonucleic Acid/i, 'DNA']
    ])
    illegal_after_normalizing(/[\.]/)
  end
  
  indexes do
    heuristics = Query::Heuristics.new [:title, :author] => 5,
                                       [:author, :year]  => 2
                                       
    # TODO Rename to Similarity::DoubleLevenshtone
    #
    few_similarities = Cacher::Similarity::DoubleLevenshtone.new 3
    
    index :main,
          "SELECT title, author, year FROM books",
          title_with_similarity,
          author,
          year,
          :heuristics => heuristics
          
    index :isbn,
          "SELECT isbn FROM books",
          field(:isbn, :qualifiers => [:i, :isbn])
          
    similar_title = field :title,  :similarity => few_similarities,
                                   :qualifiers => [:t, :title, :titre]
    author        = field :author, :qualifiers => [:a, :author, :auteur]
    year          = field :year,   :partial => Cacher::Partial::None.new,
                                   :qualifiers => [:y, :year, :annee]
  end
  
end