module Configuration
  
  # 
  #
  class Queries
    
    #
    #
    def default_index
      Tokenizers::Query.new
    end
    delegate :removes_characters, :contracts_expressions, :stopwords, :splits_text_on, :normalizes_words, :removes_characters_after_splitting, :to => :default_index
    
    # Delegates.
    #
    def maximum_tokens amount
      Query::Tokens.maximum = amount
    end
    
  end
  
end