# coding: utf-8
#
class PickySearch < Application
  
  # A simple example.
  #
  # queries do
  #   route '^/books/full', Query::Full.new(Indexes[:main])
  #   route '^/books/live', Query::Live.new(Indexes[:main])
  #   
  #   root 200
  # end
  # indexes do
  #   title   = field :title,  :similarity => Similarity::DoubleLevenshtone.new(3)
  #   author  = field :author
  #   year    = field :year,   :partial => Partial::None.new
  #   
  #   index :main,
  #         "SELECT title, author, year FROM books",
  #         title,
  #         author,
  #         year
  # end
  
  # 1. Querying.
  #
  # a) Where you define what Picky does with your search text
  #    before searching.
  # b) Where you define how Picky maps URLs to queries.
  #
  # Options:
  # * tokenizer:    # default: Tokenizers::Query.new
  # * query_key:    # default: 'query'
  # * offset_key:   # default: 'offset'
  # * content_type: # default: 'application/octet-stream'
  #
  # Methods inside:
  #  # TODO Why a string?
  #  * route <path regexp>, <query>
  #  * root <html status code>
  #
  queries do |queries|
    
    # Where you define what Picky does with your search text
    # before searching.
    #
    # Note: Usually it is a good idea to use similar
    #       or the same definitions as in the indexing step.
    
    # The maximum amount of tokens that are passed to a query.
    #
    queries.maximum_tokens 5
    
    #
    #
    queries.illegal_characters(/[()']/)
    
    #
    #
    queries.contract_expressions(/mr\.\s*|mister\s*/i, 'mr')
    
    #
    #
    queries.stopwords(/\b(and|the|or|on)/i)
    
    #
    #
    queries.split_text_on(/[\s\/\-\,\&]+/)
    
    #
    #
    queries.normalize_words([
      [/Deoxyribonucleic Acid/i, 'DNA']
    ])
    
    #
    #
    queries.illegal_characters_after(/[\.]/)
    
    # Routing.
    #
    queries.route '^/books/full', Query::Full.new(Indexes[:main], Indexes[:isbn])
    queries.route '^/books/live', Query::Live.new(Indexes[:main], Indexes[:isbn])
    
    queries.route '^/isbn/full',  Query::Full.new(Indexes[:isbn])
    
    queries.root 200 # Heartbeat check by web front server.
  end
  
  # Part 2: Indexing parameters.
  #
  # Where you define how Picky processes your data
  # while indexing (per default).
  # For specific indexes, see TODO.
  #
  # Options:
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
  indexes :partial => Cacher::Partial::Subtoken.new, :similarity => Cacher::Similarity::None.new do
    # Denote illegal characters with a regexp.
    # These are removed first.
    #
    # Default: Nothing is illegal.
    #
    illegal_characters(/[',\(\)#:!@]/)
    
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
    
    #
    #
    
    few_similarities = Similarity::DoubleLevenshtone.new(3)
    
    # We define a few fields that are used in the indexes.
    #
    # Note: They could also be defined right with the index
    #       definition below. It's just Ruby.
    #       
    #
    similar_title = field :title,  :similarity => few_similarities,
                                   :qualifiers => [:t, :title, :titre]
    author        = field :author, :qualifiers => [:a, :author, :auteur]
    year          = field :year,   :partial    => Partial::None.new,
                                   :qualifiers => [:y, :year, :annee]
    
    #
    #
    
    # 
    #
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