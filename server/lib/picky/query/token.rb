module Picky

  module Query

    # This is a query token. Together with other tokens it makes up a query.
    #
    # It remembers the original form, and and a normalized form.
    #
    # It also knows whether it needs to look for similarity (bla~),
    # or whether it is a partial (bla*).
    #
    class Token # :nodoc:all

      attr_reader :text, :original
      attr_writer :similar
      attr_accessor :user_defined_categories

      delegate :blank?,
               :to => :text

      # Normal initializer.
      #
      # Note:
      # Use this if you do not want a normalized token.
      #
      def initialize text, original = nil, category = nil
        @text     = text
        @original = original
        @user_defined_categories = [category] if category
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
      # TODO Rename @user_defined_categories. It could now also be predefined by the query.
      #
      def categorize mapper
        @user_defined_categories ||= extract_predefined mapper
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
      @@no_partial = /\"\z/
      @@partial    = /\*\z/
      def partialize
        self.partial = false or return unless @text !~ @@no_partial
        self.partial = true unless @text !~ @@partial
      end

      # If the text ends with ~ similarize it. If with ", don't.
      #
      # The latter wins.
      #
      @@no_similar = /\"\z/
      @@similar    = /\~\z/
      def similarize
        self.similar = false or return unless @text !~ @@no_similar
        self.similar = true unless @text !~ @@similar
      end

      def similar?
        @similar
      end

      # Normalizes this token's text.
      #
      @@illegals = /["*~]/
      def remove_illegals
        @text.gsub! @@illegals, EMPTY_STRING unless @text.blank?
      end

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
          self.class.new similar, similar, category
        end
      end

      # Splits text into a qualifier and text.
      #
      @@split_qualifier_text = ':'
      @@split_qualifiers     = ','
      def qualify
        @qualifiers, @text = (@text || EMPTY_STRING).split(@@split_qualifier_text, 2)
        @qualifiers, @text = if @text.blank?
          [nil, (@qualifiers || EMPTY_STRING)]
        else
          [@qualifiers.split(@@split_qualifiers), @text]
        end
        # if @text.blank?
        #   @qualifiers = nil
        #   @text = @qualifiers || EMPTY_STRING
        # else
        #   @qualifiers = @qualifiers.split @@split_qualifiers
        # end
      end

      # Internally, qualifiers are nil if there are none.
      # This returns an empty array in this case for a nicer API.
      #
      def qualifiers
        @qualifiers || []
      end

      #
      #
      def to_result
        [@original, @text]
      end

      # Internal identifier.
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