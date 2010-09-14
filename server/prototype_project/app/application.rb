# coding: utf-8
#
class BookSearch < Application
  
  # Part 1: Defaults.
  #
  # Where you define defaults for the rest of the application.
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
  
  # Part 2: Routing.
  #
  # Where you define how Picky maps URLs to queries.
  #
  # Methods:
  #  # TODO Why a string?
  #  * route <path regexp>, <query>
  #  * root <html status code>
  #
  routing do
    route '^/books/full', Query::Full.new(Indexes[:main], Indexes[:isbn])
    route '^/books/live', Query::Live.new(Indexes[:main], Indexes[:isbn])
    
    route '^/isbn/full',  Query::Full.new(Indexes[:isbn])
    
    root 200 # Heartbeat check by web front server.
  end
  
  # Part 3: Indexing parameters.
  #
  # Where you define how Picky indexes your data (per default).
  # For specific indexes, see TODO.
  # 
  indexing do
    # Denote illegal characters with a regexp.
    # These are removed first.
    #
    # Default: Nothing is illegal.
    #
    illegal(/[',\(\)#:!@]/)
    
    # Define contractions.
    #
    # Default: No contractions.
    #
    contract(/mr\.\s*|mister\s*/i, 'mr')
    
    # Stopwords are removed from the search text.
    #
    # Default: No stopwords.
    #
    stopwords(/\b(and|the|or|on)\b/)
    
    # Split the search text into tokens based on the given delimiters.
    #
    # Default: Split on \s.
    #
    split_on(/[\s\/\-\"\&\.]/)
    
    # 
    #
    illegal_after_normalizing(/[\.]/)
  end
  
  # Part 4: Query parameters.
  #
  # Where you define what Picky does with your search text
  # before searching.
  #
  # Note: Usually it is a good idea to use similar
  #       or the same definitions as in the indexing step.
  #
  querying do
    # The maximum amount of tokens that are passed to a query.
    #
    maximum_tokens 5
    
    #
    #
    illegal(/[()']/)
    
    #
    #
    contract(/mr\.\s*|mister\s*/i, 'mr')
    
    #
    #
    stopwords(/\b(and|the|or|on)/i)
    
    #
    #
    split_on(/[\s\/\-\,\&]+/)
    
    #
    #
    normalizing_word_patterns([
      [/^Deoxyribonucleic Acid/i, 'DNA']
    ])
    
    #
    #
    illegal_after_normalizing(/[\.]/)
  end
  
  # Part 5: Indexes.
  #
  # Where you define where your data comes from and into which indexes
  # it is put.
  #
  # Also...
  #
  indexes do
    few_similarities = Similarity::DoubleLevenshtone.new(3)
    
    similar_title = field :title,  :similarity => few_similarities,
                                   :qualifiers => [:t, :title, :titre]
    author        = field :author, :qualifiers => [:a, :author, :auteur]
    year          = field :year,   :partial => Partial::None.new,
                                   :qualifiers => [:y, :year, :annee]
                                   
    index :main,
          "SELECT title, author, year FROM books",
          title_with_similarity,
          author,
          year,
          :heuristics => Query::Heuristics.new([:title,  :author] => 5,
                                               [:author, :year]   => 2)
                                               
    index :isbn,
          "SELECT isbn FROM books",
          field(:isbn, :qualifiers => [:i, :isbn])
  end
end