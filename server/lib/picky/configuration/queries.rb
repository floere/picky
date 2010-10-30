module Configuration
  
  # 
  #
  class Queries
    
    #
    #
    def default_tokenizer options = {}
      @default_tokenizer ||= Tokenizers::Query.new(options)
    end
    
  end
  
end