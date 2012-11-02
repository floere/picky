module Picky

  module Query

    # This is a query token. Together with other tokens it makes up a query.
    #
    # It remembers the original form, and and a normalized form.
    #
    # It also knows whether it needs to look for similarity (bla~),
    # or whether it is a partial (bla*).
    #
    class Token

      attr_reader :text, :original
      attr_writer :similar
      attr_accessor :predefined_categories
      
      delegate :blank?, :to => :@text
      
      # Normal initializer.
      #
      # Note:
      # Use this if you do not want a normalized token.
      #
      # TODO Throw away @predefined_categories?
      #
      def initialize text, original = nil, categories = nil
        @text     = text
        @original = original
        @predefined_categories = categories
      end

      # Returns a qualified and normalized token.
      #
      # Note:
      # Use this in the search engine if you need a qualified
      # and normalized token. I.e. one prepared for a search.
      #
      def self.processed text, original = nil
        new(text, original).process
      end
      def process
        qualify
        partialize
        similarize
        remove_illegals
        self
      end

      # Symbolizes this token's text.
      #
      # Note:
      # Call externally when Picky operates in Symbols mode.
      #
      def symbolize!
        @text = @text.to_sym
      end

      # Translates this token's qualifiers into actual categories.
      #
      # Note: If this is not done, there is no mapping.
      # Note: predefined is an Array of mapped categories.
      #
      # TODO Do we really need to set the predefined categories on the token?
      #
      def categorize mapper
        @predefined_categories ||= extract_predefined mapper
      end
      def extract_predefined mapper
        user_qualified = categorize_with mapper, @qualifiers
        mapper.restrict user_qualified
      end
      def categorize_with mapper, qualifiers
        qualifiers && qualifiers.map do |qualifier|
          mapper.map qualifier
        end.compact
      end

      # Partial is a conditional setter.
      #
      # It is only settable if it hasn't been set yet.
      #
      def partial= partial
        @partial = partial if @partial.nil?
      end

      # A token is partial? only if it not similar
      # and is partial.
      #
      # It can't be similar and partial at the same time.
      #
      def partial?
        !@similar && @partial
      end

      # If the text ends with *, partialize it. If with ",
      # non-partialize it.
      #
      # The last one wins.
      # So "hello*" will not be partially searched.
      # So "hello"* will be partially searched.
      #
      @@no_partial_character = '"'
      @@partial_character = '*'
      @@no_partial = /\"\z/
      @@partial    = /\*\z/
      def partialize
        self.partial = false or return unless @text !~ @@no_partial
        self.partial = true unless @text !~ @@partial
      end
      # Define a character which stops a token from
      # being a partial token, even if it is the last token.
      #
      # Default is '"'.
      #
      # This is used in a regexp (%r{#{char}\z}) for String#!~, 
      # so escape the character.
      #
      # Example:
      #   Picky::Query::Token.no_partial_character = '\?'
      #   try.search("tes?") # Won't find "test".
      #
      def self.no_partial_character= character
        @@no_partial_character = character
        @@no_partial = %r{#{character}\z}
      end
      # Define a character which makes a token a partial token.
      #
      # Default is '*'.
      #
      # This is used in a regexp (%r{#{char}\z}) for String#!~, 
      # so escape the character.
      #
      # Example:
      #   Picky::Query::Token.partial_character = '\?'
      #   try.search("tes?") # Will find "test".
      #
      def self.partial_character= character
        @@partial_character = character
        @@partial = %r{#{character}\z}
        redefine_illegals
      end

      # If the text ends with ~ similarize it. If with ", don't.
      #
      # The latter wins.
      #
      @@no_similar_character = '"'
      @@similar_character = '~'
      @@no_similar = %r{#{@@no_similar_character}\z}
      @@similar    = %r{#{@@similar_character}\z}
      def similarize
        self.similar = false or return unless @text !~ @@no_similar
        self.similar = true unless @text !~ @@similar
      end
      # Define a character which stops a token from
      # being a similar token, even if it is the last token.
      #
      # Default is '"'.
      #
      # This is used in a regexp (%r{#{char}\z}) for String#!~, 
      # so escape the character.
      #
      # Example:
      #   Picky::Query::Token.no_similar_character = '\?'
      #   try.search("tost?") # Won't find "test".
      #
      def self.no_similar_character= character
        @@no_similar_character = character
        @@no_similar = %r{#{character}\z}
      end
      # Define a character which makes a token a similar token.
      #
      # Default is '~'.
      #
      # This is used in a regexp (%r{#{char}\z}) for String#!~, 
      # so escape the character.
      #
      # Example:
      #   Picky::Query::Token.similar_character = '\?'
      #   try.search("tost?") # Will find "test".
      #
      def self.similar_character= character
        @@similar_character = character
        @@similar = %r{#{character}\z}
        redefine_illegals
      end
      
      # Is this a "similar" character?
      #
      def similar?
        @similar
      end

      # Normalizes this token's text.
      #
      def remove_illegals
        # Note: unless @text.blank? was removed.
        #
        @text.gsub! @@illegals, EMPTY_STRING unless @text == EMPTY_STRING
      end
      def self.redefine_illegals
        @@illegals = %r{[#{@@no_similar_character}#{@@partial_character}#{@@similar_character}]}
      end
      redefine_illegals

      # Returns an array of possible combinations.
      #
      def possible_combinations_in index
        index.possible_combinations self
      end

      # Returns all similar tokens for the token.
      #
      def similar_tokens_for category
        similars = category.bundle_for(self).similar @text
        similars.map do |similar|
          # The array describes all possible categories. There is only one here.
          #
          self.class.new similar, similar, [category]
        end
      end

      # Splits text into a qualifier and text.
      #
      @@qualifier_text_delimiter = ':'
      @@qualifiers_delimiter     = ','
      def qualify
        @qualifiers, @text = (@text || EMPTY_STRING).split(@@qualifier_text_delimiter, 2)
        if @text
          @qualifiers = @qualifiers.split @@qualifiers_delimiter
        else
          @text = @qualifiers || EMPTY_STRING
          @qualifiers = nil
        end
      end
      # Define a character which separates the qualifier
      # from the search text.
      #
      # Default is ':'.
      #
      # This is used in a String#split.
      #
      # Example:
      #   Picky::Query::Token.qualifier_text_delimiter = '?'
      #   try.search("text1?hello text2?world").ids.should == [1]
      #
      def self.qualifier_text_delimiter= character
        @@qualifier_text_delimiter = character
      end
      # Define a character which separates the qualifiers
      # (before the search text).
      #
      # Default is ','.
      #
      # This is used in a String#split.
      #
      # Example:
      #   Picky::Query::Token.qualifiers_delimiter = '|'
      #   try.search("text1|text2:hello").ids.should == [1]
      #
      
      def self.qualifiers_delimiter= character
        @@qualifiers_delimiter = character
      end
      
      # Returns the qualifiers as an array.
      #
      # Example:
      #   token.qualifiers # => ['title', 'author']
      #   token.qualifiers # => []
      #
      # Note: Internally, qualifiers are nil if there are none.
      #
      def qualifiers
        @qualifiers || []
      end

      # Returns the token in the form
      #   ['original:Text', 'processedtext']
      #
      def to_result
        [@original, @text]
      end

      # Internal identifier.
      #
      # Note: Used in many backends.
      #
      def identifier
        "#{similar?? :similarity : :inverted}:#{@text}"
      end

      # If the originals & the text are the same, they are the same.
      #
      def == other
        self.original == other.original && self.text == other.text
      end

      # Displays the text and the qualifiers.
      #
      # e.g. name:meier
      #
      def to_s
        "#{self.class}(#{[@text, (@qualifiers.inspect unless @qualifiers.blank?)].compact.join(', ')})"
      end

    end

  end

end