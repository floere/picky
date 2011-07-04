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

    # Does not actually return a token, but a
    # symbol "token".
    #
    def tokens_for words
      words.collect! { |word| word.downcase! if downcase?; word.to_sym }
    end
    # Returns empty tokens.
    #
    def empty_tokens
      []
    end

  end

end