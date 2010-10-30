# encoding: utf-8
#
module Tokenizers
  
  # There are a few class methods that you can use to configure how a query works.
  #
  # removes_characters regexp
  # illegal_after_normalizing regexp
  # stopwords regexp
  # contracts_expressions regexp, to_string
  # splits_text_on regexp
  # normalizes_words [[/regexp1/, 'replacement1'], [/regexp2/, 'replacement2']]
  #
  class Query < Base
    
    cattr_accessor :default
    
    attr_reader :maximum_tokens
    
    def initialize options = {}
      super options
      @maximum_tokens = options[:maximum_tokens] || 5
    end
    
    def preprocess text
      remove_illegals text             # Remove illegal characters
      remove_non_single_stopwords text # remove stop words
      contract text                    # contract st sankt etc
      text
    end
    
    # Split the text and put some back together.
    #
    # TODO Make the same as in indexing?
    #
    def pretokenize text
      split text
    end
    
    # Let each token process itself.
    # Reject, limit, and partialize tokens.
    #
    def process tokens
      tokens.tokenize_with self
      tokens.reject              # Reject any tokens that don't meet criteria
      tokens.cap maximum_tokens  # Cut off superfluous tokens
      tokens.partialize_last     # Set certain tokens as partial
      tokens
    end
    
    # Called by the token.
    #
    # TODO Perhaps move to Normalizer?
    #
    def normalize text
      text = substitute_characters text # Substitute special characters TODO Move to subclass
      text.downcase!                    # Downcase all text
      normalize_with_patterns text      # normalize
      text.to_sym                       # symbolize
    end
    
    # Returns a token for a word.
    # The basic query tokenizer uses new tokens.
    #
    def token_for word
      ::Query::Token.processed word
    end
    
  end
end