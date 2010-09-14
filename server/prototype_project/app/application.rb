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
  #      * Options:
  #        * down_to:     At which character it should stop. 1 to n.
  #        * starting_at: Which character it should start at. -1 to -n.
  #  * similarity:
  #    * Cacher::Similarity::None.new                 # Default. Doesn't generate a similarity index.
  #    * Cacher::Similarity::DoubleLevenshtone.new(n) # Generates a similarity index with n similar tokens per token.
  #
  defaults do
    partial Cacher::Partial::Subtoken.new
    # or
    # partial Cacher::Partial::Subtoken.new
    # or
    # partial Cacher::Partial::Subtoken.new :down_to => 4, :starting_at => -1
    
    similarity Cacher::Similarity::None.new
    # or
    # similarity Cacher::Similarity::DoubleLevenshtone.new
    # or
    # similarity Cacher::Similarity::DoubleLevenshtone.new(2)
  end
  
  # This example
  #
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