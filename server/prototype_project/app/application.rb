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
    # Heuristics.
    #
    heuristics = Query::Heuristics.new [:title, :author] => 5,
                                       [:author, :year]  => 2
    
    # Convenience variables for the index definitions.
    #
    double_levenshtone_with_few_similarities = Cacher::Similarity::DoubleLevenshtone.new 3

    title_with_similarity      = field :title,
                                       :similarity => double_levenshtone_with_few_similarities,
                                       :qualifiers => [:t, :title, :titre]
    author_with_similarity     = field :author,
                                       :similarity => double_levenshtone_with_few_similarities,
                                       :qualifiers => [:a, :author, :auteur]
    blurb                      = field :blurb,
                                       :qualifiers => [:b, :blurb, :rabat]
    year                       = field :year,
                                       :partial => Cacher::Partial::None.new,
                                       :qualifiers => [:y, :year, :annee]
    
    type :main,
         "SELECT title, author, blurb, year FROM books",
         title_with_similarity,
         author_with_similarity,
         blurb,
         year,
         :result_type => 'm',
         :heuristics => heuristics
         
    type :isbn,
         "SELECT isbn FROM books",
         field(:isbn, :qualifiers => [:i, :isbn])
  end
end