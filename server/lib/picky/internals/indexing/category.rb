module Internals

  module Indexing

    class Category

      attr_reader :exact, :partial, :name, :configuration

      delegate :identifier, :prepare_index_directory, :to => :configuration
      delegate :source, :source=, :tokenizer, :tokenizer=, :to => :indexer

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
      #
      def initialize name, index, options = {}
        @name = name
        @from = options[:from]

        # Now we have enough info to combine the index and the category.
        #
        @configuration = Configuration::Index.new index, self

        @tokenizer = options[:tokenizer] || Tokenizers::Index.default
        @source    = options[:source]    # TODO || raise("...")?

        # TODO Push into Bundle. At least the weights.
        #
        partial    = options[:partial]    || Generators::Partial::Default
        weights    = options[:weights]    || Generators::Weights::Default
        similarity = options[:similarity] || Generators::Similarity::Default

        bundle_class = options[:indexing_bundle_class] || Bundle::Memory
        @exact   = bundle_class.new(:exact,   configuration, similarity, Generators::Partial::None.new, weights)
        @partial = bundle_class.new(:partial, configuration, Generators::Similarity::None.new, partial, weights)
      end

      def to_s
        <<-CATEGORY
Category(#{name} from #{from}):
  Exact:
#{exact.indented_to_s(4)}
  Partial:
#{partial.indented_to_s(4)}
        CATEGORY
      end

      # The indexer is lazily generated and cached.
      #
      def indexer
        @indexer ||= Indexers::Serial.new configuration, @source, @tokenizer
      end

      # Where the data is taken from.
      #
      def from
        @from || name
      end

      def backup_caches
        timed_exclaim "Backing up #{identifier}."
        exact.backup
        partial.backup
      end
      def restore_caches
        timed_exclaim "Restoring #{identifier}."
        exact.restore
        partial.restore
      end
      def check_caches
        timed_exclaim "Checking #{identifier}."
        exact.raise_unless_cache_exists
        partial.raise_unless_cache_exists
      end
      def clear_caches
        timed_exclaim "Deleting #{identifier}."
        exact.delete
        partial.delete
      end

      def index
        prepare_index_directory
        indexer.index
      end

      # Generates all caches for this category.
      #
      def cache
        prepare_index_directory
        configure
        generate_caches
      end
      # We need to set what formatting method should be used.
      # Uses the one defined in the indexer.
      #
      def configure
        key_format = indexer.key_format
        exact[:key_format] = key_format
        partial[:key_format] = key_format
      end
      def generate_caches
        generate_caches_from_source
        generate_partial
        generate_caches_from_memory
        dump_caches
        timed_exclaim %Q{"#{identifier}": Caching finished.}
      end
      def generate_caches_from_source
        exact.generate_caches_from_source
      end
      def generate_partial
        partial.generate_partial_from exact.index
      end
      def generate_caches_from_memory
        partial.generate_caches_from_memory
      end
      def dump_caches
        exact.dump
        partial.dump
      end

    end

  end

end