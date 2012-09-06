module Picky

  class Category

    include API::Tokenizer
    include API::Source
    include API::Category::Weight
    include API::Category::Partial
    include API::Category::Similarity

    attr_accessor :exact,
                  :partial
    attr_reader :name,
                :prepared,
                :backend

    # Parameters:
    #  * name: Category name to use as identifier and file names.
    #  * index: Index to which this category is attached to.
    #
    # Options:
    #  * partial: Partial::None.new, Partial::Substring.new(from:start_char, to:up_to_char)
    #  (defaults from:-3, to:-1)
    #  * similarity: Similarity::None.new (default),
    #  Similarity::DoubleMetaphone.new(amount_of_similarly_linked_words)
    #  * from: The source category identifier to take the data from.
    #  * key_format: What this category's keys are formatted with (default is :to_i)
    #  * backend: The backend to use. Default is Backends::Memory.new.
    #  Other options are: Backends::Redis.new, Backends::SQLite.new, Backends::File.new.
    #  * qualifiers: Which qualifiers can be used to predefine the category. E.g. "title:bla".
    #
    # Advanced Options:
    #  * source: Use if the category should use a different source.
    #  * tokenizer: Use a subclass of Tokenizers::Base that implements #tokens_for and #empty_tokens.
    #  * weight: Weights::Logarithmic.new, Weights::Constant.new(int = 0),
    #  Weights::Dynamic.new(&block) or an object that responds
    #  to #weight_for(amount_of_ids_for_token) and returns a float.
    #
    def initialize name, index, options = {}
      @name  = name
      @index = index

      configure_from options
      configure_indexes_from options
    end
    
    def configure_from options
      # Indexing.
      #
      @source    = extract_source options[:source], nil_ok: true
      @from      = options[:from]
      @tokenizer = extract_tokenizer options[:indexing]

      @key_format = options.delete :key_format
      @backend    = options.delete :backend

      @qualifiers = extract_qualifiers_from options

      # @symbols    = options[:use_symbols] || index.use_symbols? # SYMBOLS.
    end

    def configure_indexes_from options
      weights    = extract_weight options[:weight]
      partial    = extract_partial options[:partial]
      similarity = extract_similarity options[:similarity]

      no_partial    = Generators::Partial::None.new
      no_similarity = Generators::Similarity::None.new

      @exact = Bundle.new :exact, self, weights, no_partial, similarity, options
      if partial.respond_to?(:use_exact_for_partial?) && partial.use_exact_for_partial?
        @partial = Wrappers::Bundle::ExactPartial.new @exact
      else
        @partial = Bundle.new :partial, self, weights, partial, no_similarity, options
      end

      @prepared = Backends::Prepared::Text.new prepared_index_path
    end

    # Indexes and loads the category.
    #
    def reindex
      index
      load
    end

    # Dumps both bundles.
    #
    def dump
      exact.dump
      partial.dump
      Picky.logger.dump self
    end

    # Returns the backend.
    #
    # If no specific backend has been defined for this
    #
    def backend
      @backend || @index.backend
    end
    # Resets backends in both bundles.
    #
    def reset_backend
      exact.reset_backend
      partial.reset_backend
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
      @prepared_index_path ||= ::File.join(index_directory, name.to_s)
    end
    # Get an opened index file.
    #
    # Note: If you don't use it with the block, do not forget to close it.
    #
    def prepared_index_file &block
      @prepared_index_file ||= Backends::Prepared::Text.new prepared_index_path
      @prepared_index_file.open &block
    end

    # The index directory for this category.
    #
    def index_directory
      @index_directory ||= ::File.join(PICKY_ROOT, 'index', PICKY_ENVIRONMENT, @index.name.to_s)
    end

    # Identifier for technical output.
    #
    def identifier
      :"#{@index.identifier}:#{name}"
    end

    #
    #
    def to_s
      "#{self.class}(#{identifier})"
    end

  end

end