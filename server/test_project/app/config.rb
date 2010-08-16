# Books example app.
#

def Configuration.apply

  # Tokenizing during indexing.
  #
  Tokenizers::Index.illegal(/[',\(\)#:!@]/)
  Tokenizers::Index.illegal_after_normalizing(/[\.]/)
  Tokenizers::Index.stopwords(/\b(and|the|or|on)\b/)
  Tokenizers::Index.split_on(/[\s\/\-\"\&\.]/)

  # Tokenizing in a query.
  #
  Query::Tokens.maximum = 5
  Tokenizers::Query.illegal(/[()']/)
  Tokenizers::Query.illegal_after_normalizing(/[\.]/)
  Tokenizers::Query.stopwords(/\b(and|the|or|on)/i)
  Tokenizers::Query.contract(/mr\.\s*|mister\s*/i, 'st')
  Tokenizers::Query.split_on(/[\s\/\-\,\&]+/) # \+ ?
  Tokenizers::Query.normalizing_word_patterns([
    [/^Deoxyribonucleic Acid/i,  'DNA']
  ])

  # How many results to return.
  #
  # Results::Full.max_results = 20
  
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
  isbn                       = field :isbn,
                                     # :indexer => Indexers::ISBN,
                                     # :tokenizer => Tokenizers::ISBN,
                                     :qualifiers => [:i, :isbn]
  year                       = field :year,
                                     :partial => Cacher::Partial::None.new,
                                     :qualifiers => [:y, :year, :annee]
                                     
  # Heuristics for: What allocations to promote.
  # 6 is basically always on top. 1 is a very small nudge.
  #
  heuristics = Query::Heuristics.new [:title, :author] => 5,
                                     [:author, :year]  => 2
                                     
  # Configure the indexes.
  #
  indexes type(:main,
               "SELECT title, author, blurb, year FROM books", # autoselect?
               title_with_similarity,
               author_with_similarity,
               blurb,
               year,
               :result_type => 'm',
               :heuristics => heuristics
          ),
          type(:isbn,
               "SELECT isbn FROM books",
               isbn
          )
          
end