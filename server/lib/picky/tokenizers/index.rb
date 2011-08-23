module Picky

  module Tokenizers

    # The base indexing tokenizer.
    #
    # Override in indexing subclasses and define in configuration.
    #
    class Index < Base

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