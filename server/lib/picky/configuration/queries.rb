module Configuration
  
  # 
  #
  class Queries
    
    #
    #
    def default_tokenizer
      @default_tokenizer ||= Tokenizers::Default::Query
    end
    
    delegate :removes_characters, :contracts_expressions, :stopwords, :splits_text_on, :normalizes_words, :removes_characters_after_splitting, :to => :default_tokenizer
    
    # Delegates.
    #
    def maximum_tokens amount
      Query::Tokens.maximum = amount
    end
    
  end
  
end