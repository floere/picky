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
    # rejects_token_if &condition
    # normalizes_words [[/regexp1/, 'replacement1'], [/regexp2/, 'replacement2']]
    #
    class Query < Base

      #
      #
      def self.default= new_default
        @default = new_default
      end
      def self.default
        @default ||= new
      end

    end

  end

end