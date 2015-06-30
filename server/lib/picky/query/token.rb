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
      
      attr_accessor :text, :original
      attr_writer :similar
      attr_writer :predefined_categories
      
      forward :blank?, :to => :@text
      
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
        similarize
        partialize
        rangify
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
      def predefined_categories mapper = nil
        @predefined_categories || mapper && extract_predefined(mapper)
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
      
      # Selects the bundle to be used.
      #
      def select_bundle exact, partial
        @partial ? partial : exact
      end
      
      # Generates a reused stem.
      #
      # Caches a stem for a tokenizer.
      #
      def stem tokenizer
        if stem?
          @stems ||= Hash.new
          @stems[tokenizer] ||= tokenizer.stem(@text)
        else
          @text
        end
      end
      def stem?
        @text !~ @@no_partial
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
      # Note: @partial is calculated at processing time (see Token#process).
      #
      def partial?
        # Was: !@similar && @partial
        @partial
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
        # A token is partial? only if it not similar
        # and is partial.
        #
        # It can't be similar and partial at the same time.
        #
        self.partial = false or return if @similar
        self.partial = false or return if @text =~ @@no_partial
        self.partial = true if @text =~ @@partial
      end
      # Define a character which stops a token from
      # being a partial token, even if it is the last token.
      #
      # Default is '"'.
      #
      # This is used in a regexp (%r{#{char}\z}) for String#=~, 
      # so escape the character.
      #
      # Example:
      #   Picky::Query::Token.no_partial_character = '\?'
      #   try.search("tes?") # Won't find "test".
      #
      def self.no_partial_character= character
        @@no_partial_character = character
        @@no_partial = %r{#{character}\z}
        redefine_illegals
      end
      # Define a character which makes a token a partial token.
      #
      # Default is '*'.
      #
      # This is used in a regexp (%r{#{char}\z}) for String#=~, 
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
      @@no_similar = %r{#@@no_similar_character\z}
      @@similar    = %r{#@@similar_character\z}
      def similarize
        self.similar = false or return if @text =~ @@no_similar
        self.similar = true if @text =~ @@similar
      end
      # Define a character which stops a token from
      # being a similar token, even if it is the last token.
      #
      # Default is '"'.
      #
      # This is used in a regexp (%r{#{char}\z}) for String#=~, 
      # so escape the character.
      #
      # Example:
      #   Picky::Query::Token.no_similar_character = '\?'
      #   try.search("tost?") # Won't find "test".
      #
      def self.no_similar_character= character
        @@no_similar_character = character
        @@no_similar = %r{#{character}\z}
        redefine_illegals
      end
      # Define a character which makes a token a similar token.
      #
      # Default is '~'.
      #
      # This is used in a regexp (%r{#{char}\z}) for String#=~, 
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
      
      # Define a character which makes a token a range token.
      #
      # Default is '…'.
      #
      # Example:
      #   Picky::Query::Token.range_character = "-"
      #   try.search("year:2000-2008") # Will find results in a range.
      #
      @@range_character = ?…
      def self.range_character= character
        @@range_character = character
      end
      def rangify
        @range = @text.split(@@range_character, 2) if @text.include? @@range_character
      end
      def range
        @range
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
        # Note: By default, both no similar and no partial are ".
        #
        @@illegals = %r{[#@@no_similar_character#@@similar_character#@@no_partial_character#@@partial_character]}
      end
      redefine_illegals
      
      # Return all possible combinations.
      #
      # This checks if it needs to also search through similar
      # tokens, if for example, the token is one with ~.
      # If yes, it puts together all solutions.
      #
      def possible_combinations categories
        similar? ? categories.similar_possible_for(self) : categories.possible_for(self)
      end
      
      # If the Token has weight for the given category,
      # it will return a new combination for the tuple
      # (self, category, weight).
      #
      def combination_for category
        weight = category.weight self
        weight && Query::Combination.new(self, category, weight)
      end

      # Returns all similar tokens for the token.
      #
      def similar_tokens_for category
        similars = category.similar self
        similars.map do |similar|
          # The array describes all possible categories. There is only one here.
          #
          self.class.new similar, similar, [category]
        end
      end

      # Splits text into a qualifier and text.
      #
      @@qualifier_text_delimiter = /:/
      @@qualifiers_delimiter     = /,/
      # TODO Think about making these instances.
      @@qualifier_text_splitter  = Splitter.new @@qualifier_text_delimiter
      @@qualifiers_splitter      = Splitter.new @@qualifiers_delimiter
      def qualify
        @qualifiers, @text = @@qualifier_text_splitter.single @text
        if @qualifiers
          @qualifiers = @@qualifiers_splitter.multi @qualifiers
        end
      end
      # Define a regexp which separates the qualifier
      # from the search text.
      #
      # Default is /:/.
      #
      # Example:
      #   Picky::Query::Token.qualifier_text_delimiter = /\?/
      #   try.search("text1?hello text2?world").ids.should == [1]
      #
      def self.qualifier_text_delimiter= character
        @@qualifier_text_delimiter = character
        @@qualifier_text_splitter  = Splitter.new @@qualifier_text_delimiter
      end
      # Define a regexp which separates the qualifiers
      # (before the search text).
      #
      # Default is /,/.
      #
      # Example:
      #   Picky::Query::Token.qualifiers_delimiter = /|/
      #   try.search("text1|text2:hello").ids.should == [1]
      #
      
      def self.qualifiers_delimiter= character
        @@qualifiers_delimiter = character
        @@qualifiers_splitter  = Splitter.new @@qualifiers_delimiter
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
        "#{similar?? :similarity : :inverted}:#@text"
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
