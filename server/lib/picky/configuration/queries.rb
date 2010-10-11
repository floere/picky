module Configuration
  
  # 
  #
  class Queries
    
    #
    #
    def default_index
      Tokenizers::Query
    end
    delegate :removes_characters, :contract_expressions, :stopwords, :splits_text_on, :normalize_words, :removes_characters_after_splitting, :to => :default_index
    
    # Delegates.
    #
    def maximum_tokens amount
      Query::Tokens.maximum = amount
    end
    
  end
  
end