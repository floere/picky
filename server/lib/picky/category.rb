module Picky

  class Category

    attr_reader :name

    # Mandatory params:
    #  * name: Category name to use as identifier and file names.
    #  * index: Index to which this category is attached to.
    #
    # Options:
    #  * partial: Partial::None.new, Partial::Substring.new(from:start_char, to:up_to_char) (defaults from:-3, to:-1)
    #  * similarity: Similarity::None.new (default), Similarity::DoubleMetaphone.new(amount_of_similarly_linked_words)
    #  * from: The source category identifier to take the data from.
    #
    # Advanced Options:
    #  * source: Use if the category should use a different source.
    #  * weights: Query::Weights.new( [:category1, :category2] => +2, ... )
    #  * tokenizer: Use a subclass of Tokenizers::Base that implements #tokens_for and #empty_tokens.
    #  * key_format: What this category's keys are formatted with (default is :to_i)
    #
    def initialize name, index, options = {}
      @name  = name
      @index = index

      # Indexing.
      #
      @source     = options[:source]
      @from       = options[:from]
      @tokenizer  = options[:tokenizer]
      @key_format = options[:key_format]
      @qualifiers = extract_qualifiers_from options

      weights    = options[:weights]    || Generators::Weights::Default
      partial    = options[:partial]    || Generators::Partial::Default
      similarity = options[:similarity] || Generators::Similarity::Default

      no_partial    = Generators::Partial::None.new
      no_similarity = Generators::Similarity::None.new
      
      # TODO Combine indexing and indexed!
      #

      @indexing_exact   = Indexing::Bundle.new  :exact,  self, index.backend, weights, no_partial, similarity, options
      @indexing_partial = Indexing::Bundle.new :partial, self, index.backend, weights, partial, no_similarity, options

      # Indexed.
      #
      @indexed_exact  = Indexed::Bundle.new :exact, self, index.backend, weights, no_partial, similarity
      if partial.use_exact_for_partial?
        @indexed_partial  = @indexed_exact
      else
        @indexed_partial  = Indexed::Bundle.new :partial, self, index.backend, weights, partial, no_similarity
      end

      # @exact   = exact_lambda.call(@exact, @partial)   if exact_lambda   = options[:exact_lambda]
      # @partial = partial_lambda.call(@exact, @partial) if partial_lambda = options[:partial_lambda]
    end

    # Indexes and reloads the category.
    #
    def reindex
      index
      reload
    end

    def dump
      indexing_exact.dump
      indexing_partial.dump
    end

    # Index name.
    #
    def index_name
      @index.name
    end

    # Returns the qualifiers if set or
    # just the name if not.
    #
    def qualifiers
      @qualifiers || [name]
    end
    # Extract qualifiers from the options.
    #
    def extract_qualifiers_from options
      options[:qualifiers] || options[:qualifier] && [options[:qualifier]]
    end

    # The category itself just yields itself.
    #
    def each_category
      yield self
    end

    # Path and partial filename of the prepared index on this category.
    #
    def prepared_index_path
      @prepared_index_path ||= "#{index_directory}/prepared_#{name}_index"
    end
    # Get an opened index file.
    #
    # Note: If you don't use it with the block, do not forget to close it.
    #
    def prepared_index_file &block
      @prepared_index_file ||= Backends::Memory::Text.new prepared_index_path
      @prepared_index_file.open &block
    end

    # The index directory for this category.
    #
    # TODO Push down into files? Yes.
    #
    def index_directory
      @index_directory ||= "#{PICKY_ROOT}/index/#{PICKY_ENVIRONMENT}/#{@index.name}"
    end

    # Identifier for technical output.
    #
    def identifier
      "#{@index.identifier}:#{name}"
    end

    #
    #
    def to_s
      "#{self.class}(#{identifier})"
    end

  end

end