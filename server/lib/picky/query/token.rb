module Query

  # This is a query token. Together with other tokens it makes up a query.
  #
  # It remembers the original form, and and a normalized form.
  #
  # It also knows whether it needs to look for similarity (bla~), or whether it is a partial (bla*).
  #
  class Token # :nodoc:all

    attr_reader :text, :original, :qualifiers, :user_defined_categories
    attr_writer :similar

    delegate :blank?, :to => :text

    # Normal initializer.
    #
    # Note: Use this if you do not want a normalized token.
    #
    def initialize text
      @text = text
    end

    # Returns a qualified and normalized token.
    #
    # Note: Use this in the search engine if you need a qualified
    #       and normalized token. I.e. one prepared for a search.
    #
    def self.processed text, downcase = true
      new(text).process downcase
    end
    def process downcased = true
      qualify
      extract_original
      downcase if downcased
      partialize
      similarize
      remove_illegals
      symbolize
      self
    end

    # Translates this token's qualifiers into actual categories.
    #
    # Note: If this is not done, there is no mapping.
    #
    def categorize mapper
      @user_defined_categories = @qualifiers && @qualifiers.map do |qualifier|
        mapper.map qualifier
      end.compact
    end

    # Dups the original text.
    #
    def extract_original
      @original = @text.dup
    end

    # Downcases the text.
    #
    def downcase
      @text.downcase!
    end

    # Partial is a conditional setter.
    #
    # It is only settable if it hasn't been set yet.
    #
    def partial= partial
      @partial = partial if @partial.nil?
    end
    def partial?
      !@similar && @partial
    end

    # If the text ends with *, partialize it. If with ", don't.
    #
    # The latter wins. So "hello*" will not be partially searched.
    #
    @@no_partial = /\"\Z/
    @@partial    = /\*\Z/
    def partialize
      self.partial = false and return unless @text !~ @@no_partial
      self.partial = true unless @text !~ @@partial
    end

    # If the text ends with ~ similarize it. If with ", don't.
    #
    # The latter wins.
    #
    @@no_similar = /\"\Z/
    @@similar    = /\~\Z/
    def similarize
      self.similar = false and return if @text =~ @@no_similar
      self.similar = true if @text =~ @@similar
    end

    def similar?
      @similar
    end

    # Normalizes this token's text.
    #
    @@illegals = /["*~]/
    def remove_illegals
      @text.gsub! @@illegals, '' unless @text.blank?
    end

    #
    #
    def symbolize
      @text = @text.to_sym
    end

    # Returns an array of possible combinations.
    #
    def possible_combinations_in index
      index.possible_combinations self
    end

    # Returns a token with the next similar text.
    #
    # THINK Rewrite this. It is hard to understand. Also spec performance.
    #
    def next_similar_token category
      token = self.dup
      token if token.next_similar category.bundle_for(token)
    end
    # Sets and returns the next similar word.
    #
    # Note: Also overrides the original.
    #
    def next_similar bundle
      @text = @original = (similarity(bundle).shift || return) if similar?
    end
    # Lazy similar reader.
    #
    def similarity bundle = nil
      @similarity || @similarity = generate_similarity_for(bundle)
    end
    # Returns an enumerator that traverses over the similar.
    #
    # Note: The dup isn't too nice – since it is needed on account of the shift, above.
    #       (We avoid a StopIteration exception. Which of both is less evil?)
    #
    def generate_similarity_for bundle
      bundle.similar(@text).dup || []
    end

    # Splits text into a qualifier and text.
    #
    @@split_qualifier_text = ':'
    @@split_qualifiers     = ','
    def qualify
      @qualifiers, @text = (@text || '').split(@@split_qualifier_text, 2)
      @qualifiers, @text = if @text.blank?
        [nil, (@qualifiers || '')]
      else
        [@qualifiers.split(@@split_qualifiers), @text]
      end
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