# TODO Remove?
#
module Configuration
  
  # Describes the container for all index configurations.
  #
  class Indexes
    
    def default_tokenizer options = {}
      Tokenizers::Index.default = Tokenizers::Index.new(options)
    end
    
  end

end