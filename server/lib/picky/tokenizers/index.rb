module Tokenizers
  
  # The base indexing tokenizer.
  #
  # Override in indexing subclasses and define in configuration.
  #
  class Index < Base
    
    def self.default= new_default
      @default = new_default
    end
    def self.default
      @default ||= new
    end
    
    # Default indexing preprocessing hook.
    #
    # Does:
    # 1. Character substitution.
    # 2. Downcasing.
    # 3. Remove illegal expressions.
    # 4. Remove non-single stopwords. (Stopwords that occur with other words)
    #
    def preprocess text
      text = substitute_characters text
      text.downcase!
      remove_illegals text
      # we do not remove single stopwords for an entirely different
      # reason than in the query tokenizer.
      # An indexed thing with just name "UND" (a possible stopword) should not lose its name.
      #
      remove_non_single_stopwords text
      text
    end
    
    # Default indexing pretokenizing hook.
    #
    # Does:
    # 1. Split the text into words.
    # 2. Normalize each word.
    #
    # TODO Rename into wordize? Or somesuch?
    #
    def pretokenize text
      words = split text
      words.collect! do |word|
        normalize_with_patterns word
        word
      end
    end
    
    # Does not actually return a token, but a
    # symbol "token".
    #
    def token_for text
      symbolize text
    end
    
    # Rejects tokens if they are too short (or blank).
    #
    # Override in subclasses to redefine behaviour.
    #
    # TODO TODO TODO Make parametrizable! reject { |token| }
    #
    def reject tokens
      tokens.reject! &:blank?
      # tokens.reject! { |token| token.to_s.size < 2 }
    end
    
  end
end