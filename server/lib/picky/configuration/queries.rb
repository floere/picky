module Configuration
  
  # 
  #
  class Queries
    
    attr_reader :routing
    
    #
    #
    def initialize routing
      @routing = routing
    end
    
    #
    #
    def default_index
      Tokenizers::Query
    end
    
    # Routes.
    #
    delegate :defaults, :route, :live, :full, :root, :default, :to => :routing
    
    # Delegates.
    #
    def maximum_tokens amount
      Query::Tokens.maximum = amount
    end
    delegate :illegal_characters, :contract_expressions, :stopwords, :split_text_on, :normalize_words, :illegal_characters_after_splitting, :to => :default_index
    
  end
  
end