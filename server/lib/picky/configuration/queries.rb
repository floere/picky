module Configuration
  
  # 
  #
  class Queries
    
    #
    #
    def default_tokenizer options = {}
      Tokenizers::Query.default = Tokenizers::Query.new(options)
    end
    
  end
  
end