# encoding: utf-8
#
module Tokenizers
  
  # There are a few class methods that you can use to configure how a query works.
  #
  # illegal regexp
  # illegal_after_normalizing regexp
  # stopwords regexp
  # contract regexp, to_string
  # split_on regexp
  # normalizing_word_patterns [[/regexp1/, 'replacement1'], [/regexp2/, 'replacement2']]
  #
  class Query < Base
    
    include UmlautSubstituter
    
    # Default query tokenizer behaviour. Override in config.
    #
    illegal(//)
    illegal_after_normalizing(//)
    stopwords(//)
    contract(//, '')
    split_on(/\s/)
    normalizing_word_patterns([])

    def preprocess text
      remove_illegals text             # Remove illegal characters
      remove_non_single_stopwords text # remove stop words
      contract text                    # contract st sankt etc
      text
    end
    
    # Split the text and put some back together.
    #
    def pretokenize text
      split text
    end
    
    # Let each token process itself.
    # Reject, limit, and partialize tokens.
    #
    def process tokens
      tokens.tokenize_with self
      tokens.reject          # Reject any tokens that don't meet criteria
      tokens.cap             # Cut off superfluous tokens
      tokens.partialize_last # Set certain tokens as partial
      tokens
    end
    
    # Called by the token.
    #
    # TODO Perhaps move to Normalizer?
    #
    def normalize text
      text = substitute_umlauts text # Substitute special characters TODO Move to subclass
      text.downcase!                 # Downcase all text
      normalize_with_patterns text   # normalize
      text.to_sym                    # symbolize
    end
    
    # Returns a token for a word.
    # The basic query tokenizer uses new tokens.
    #
    def token_for word
      ::Query::Token.processed word
    end
    
  end
end