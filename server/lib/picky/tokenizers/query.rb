# encoding: utf-8
#
module Picky

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

      attr_reader :qualifiers

      def self.default= new_default
        @default = new_default
      end
      def self.default
        @default ||= new
      end

      attr_reader :maximum_tokens

      def initialize options = {}
        super options
        @maximum_tokens = options[:maximum_tokens] || 5
      end

      # Let each token process itself.
      # Reject, limit, and partialize tokens.
      #
      # In querying we work with real tokens (in indexing it's just symbols).
      #
      def process tokens
        tokens.reject                # Reject any tokens that don't meet criteria.
        tokens.cap maximum_tokens    # Cut off superfluous tokens.
        tokens.partialize_last       # Set certain tokens as partial.
        tokens
      end

      # Converts words into real tokens.
      #
      def tokens_for words
        Picky::Query::Tokens.processed words, downcase?
      end
      # Returns a tokens object.
      #
      def empty_tokens
        Picky::Query::Tokens.new
      end

    end

  end

end