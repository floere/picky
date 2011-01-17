module Query
  
  # This is a query token. Together with other tokens it makes up a query.
  #
  # It remembers the original form, and and a normalized form.
  #
  # It also knows whether it needs to look for similarity (bla~), or whether it is a partial (bla*).
  #
  # TODO Make partial / similarity char configurable.
  #
  class Token # :nodoc:all

    attr_reader :text, :original
    attr_writer :similar

    delegate :blank?, :to => :text

    # Normal initializer.
    #
    # Note: Use this if you do not want a qualified and normalized token.
    #
    def initialize text
      @text = text
    end

    # Returns a qualified and normalized token.
    #
    # Note: Use this in the search engine if you need a qualified
    #       and normalized token. I.e. one prepared for a search.
    #
    def self.processed text
      token = new text
      token.qualify
      token.extract_original
      token.partialize
      token.similarize
      token.remove_illegals
      token
    end

    # This returns a predefined category name if the user has given one.
    #
    def user_defined_category_name
      @qualifier
    end

    # Extracts a qualifier for this token and pre-assigns an allocation.
    #
    # Note: Removes the qualifier if it is not allowed.
    #
    def qualify
      @qualifier, @text = split @text
      @qualifier = Query::Qualifiers.instance.normalize @qualifier
    end
    def extract_original
      @original = @text.dup
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
    @@no_partial = /\"\Z/
    @@partial    = /\*\Z/
    def partialize
      self.partial = false and return if @text =~ @@no_partial
      self.partial = true if @text =~ @@partial
    end

    # If the text ends with ~ similarize it. If with ", don't.
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
    
    # Visitor for tokenizer.
    #
    # TODO Rewrite!!!
    #
    def tokenize_with tokenizer
      @text = tokenizer.normalize @text
    end
    # TODO spec!
    #
    # TODO Rewrite!!
    #
    def tokenized tokenizer
      tokenizer.tokenize(@text.to_s).each do |text|
        yield text
      end
    end

    # Returns an array of possible combinations.
    #
    def possible_combinations_in type
      type.possible_combinations self
    end

    #
    #
    def from token
      new_token = token.dup
      new_token.instance_variable_set :@text, @text
      new_token.instance_variable_set :@partial, @partial
      new_token.instance_variable_set :@original, @original
      new_token.instance_variable_set :@qualifier, @qualifier
      # TODO
      #
      # token.instance_variable_set :@similarity, @similarity
      new_token
    end

    # TODO Rewrite, also next_similar.
    #
    def next category
      token = from self
      token if token.next_similar category.bundle_for(token)
    end

    # Sets and returns the next similar word.
    #
    def next_similar bundle
      @text = similarity(bundle).next if similar?
    rescue StopIteration => stop_iteration
      # reset_similar # TODO
      nil # TODO
    end
    # Lazy similar reader.
    #
    def similarity bundle = nil
      @similarity || @similarity = generate_similarity_for(bundle)
    end
    # Returns an enumerator that traverses over the similar.
    #
    def generate_similarity_for bundle
      (bundle.similar(@text) || []).each
    end

    # Generates a solr term from this token.
    #
    # E.g. "name:heroes~0.75"
    #
    @@solr_fuzzy_mapping = {
      1 => :'',
      2 => :'',
      3 => :'',
      4 => :'~0.74',
      5 => :'~0.78',
      6 => :'~0.81',
      7 => :'~0.83',
      8 => :'~0.85',
      9 => :'~0.87',
     10 => :'~0.89'
    }
    @@solr_fuzzy_mapping.default = :'~0.9'
    def to_solr
      blank? ? '' : (to_s + @@solr_fuzzy_mapping[@text.size].to_s)
    end
    
    #
    #
    def to_result
      [@original, @text]
    end
    
    # Displays the qualifier text and the text, joined.
    #
    # e.g. name:meier
    #
    def to_s
      [@qualifier, @text].compact.join ':'
    end
    
    private
      
      # Splits text into a qualifier and text.
      #
      # Returns [qualifier, text].
      #
      def split unqualified_text
        qualifier, text = (unqualified_text || '').split(':', 2)
        if text.blank?
          [nil, (qualifier || '')]
        else
          [qualifier, text]
        end
      end

  end
end