module Picky

  class Category

    include API::Tokenizer

    attr_accessor :exact,
                  :partial
    attr_reader :name,
                :prepared,
                :backend

    # Mandatory params:
    #  * name: Category name to use as identifier and file names.
    #  * index: Index to which this category is attached to.
    #
    # Options:
    #  * partial: Partial::None.new, Partial::Substring.new(from:start_char, to:up_to_char) (defaults from:-3, to:-1)
    #  * similarity: Similarity::None.new (default), Similarity::DoubleMetaphone.new(amount_of_similarly_linked_words)
    #  * from: The source category identifier to take the data from.
    #  * key_format: What this category's keys are formatted with (default is :to_i)
    #  * backend: The backend to use. Default is Backends::Memory.new.
    #  Other options are: Backends::Redis.new, Backends::SQLite.new, Backends::File.new.
    #  * qualifiers: Which qualifiers can be used to predefine the category. E.g. "title:bla".
    #
    # Advanced Options:
    #  * weight: Query::Weights.new( [:category1, :category2] => +2, ... )
    #  * tokenizer: Use a subclass of Tokenizers::Base that implements #tokens_for and #empty_tokens.
    #  * use_symbols: Whether to use symbols internally instead of strings.
    #  * source: Use if the category should use a different source.
    #
    def initialize name, index, options = {}
      @name  = name
      @index = index

      # Indexing.
      #
      @source    = options[:source]
      @from      = options[:from]
      @tokenizer = extract_tokenizer options[:indexing]

      @key_format = options.delete :key_format
      @backend    = options.delete :backend

      @qualifiers = extract_qualifiers_from options

      # @symbols    = options[:use_symbols] || index.use_symbols? # TODO Symbols.

      weights    = options[:weight]     || Generators::Weights::Default
      partial    = options[:partial]    || Generators::Partial::Default
      similarity = options[:similarity] || Generators::Similarity::Default

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
      timed_exclaim %Q{  "#{identifier}": Dumped -> #{index_directory.gsub("#{PICKY_ROOT}/", '')}/#{name}_*.}
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
      @prepared_index_path ||= "#{index_directory}/prepared_#{name}_index"
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
      @index_directory ||= "#{PICKY_ROOT}/index/#{PICKY_ENVIRONMENT}/#{@index.name}"
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