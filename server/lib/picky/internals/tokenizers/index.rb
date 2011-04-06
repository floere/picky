module Internals

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

      # Postprocessing.
      #
      # In indexing, we work with symbol tokens.
      #
      def process tokens
        reject tokens # Reject any tokens that don't meet criteria
        tokens
      end

      # Does not actually return a token, but a
      # symbol "token".
      #
      def tokens_for words
        words.collect! { |word| word.to_sym }
      end
      # Returns empty tokens.
      #
      def empty_tokens
        []
      end

      # Text is downcased right away.
      #
      def downcase text
        text.downcase!
      end

    end

  end

end