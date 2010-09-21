module Configuration
  
  class Queries
    
    #
    #
    def routing
      @routing ||= Routing.new
    end
    
    # A queries simply delegates to the route set to handle a request.
    #
    def self.call env
      routing.call env
    end
    
    # Routes.
    #
    delegate :defaults, :route, :live, :full, :root, :default, :to => :routing
    
    # Delegates.
    #
    def maximum_tokens amount
      Query::Tokens.maximum = amount
    end
    delegate :illegal_characters, :contract_expressions, :stopwords, :split_text_on, :normalize_words, :illegal_characters_after, :to => :default_index
    
    
    
    def default_index
      Tokenizers::Index
    end
    
  end
  
end