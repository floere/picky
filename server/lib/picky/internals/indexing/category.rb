module Internals

  module Indexing

    class Category

      include Internals::Shared::Category

      attr_reader :name, :exact, :partial

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

        @source     = options[:source]
        @from       = options[:from]
        @tokenizer  = options[:tokenizer]
        @key_format = options[:key_format]

        # TODO Push into Bundle. At least the weights.
        #
        partial    = options[:partial]    || Generators::Partial::Default
        weights    = options[:weights]    || Generators::Weights::Default
        similarity = options[:similarity] || Generators::Similarity::Default

        bundle_class = index.bundle_class || Bundle::Memory

        @exact   = bundle_class.new(:exact,   self, similarity, Generators::Partial::None.new, weights)
        @partial = bundle_class.new(:partial, self, Generators::Similarity::None.new, partial, weights)
      end

      # Return an appropriate source.
      #
      def source
        @source || @index.source
      end
      # Return the key format.
      #
      # If the source has no key format, then
      # check for an explicit key format, and
      # if none is defined, ask the index for
      # one.
      #
      def key_format
        source.respond_to?(:key_format) && source.key_format || @key_format || @index.key_format
      end
      # The indexer is lazily generated and cached.
      #
      def indexer
        @indexer ||= source.respond_to?(:each) ? Indexers::Parallel.new(self) : Indexers::Serial.new(self)
      end
      # TODO This is a hack to get the parallel indexer working. 
      #
      def categories
        [self]
      end
      # Returns an appropriate tokenizer.
      # If one isn't set on this category, will try the index,
      # and finally the default index tokenizer.
      #
      def tokenizer
        @tokenizer || @index.tokenizer || Tokenizers::Index.default
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
      
      # API method.
      #
      def index
        prepare
        cache
      end
      
      # Indexes, creates the "prepared_..." file.
      #
      def prepare
        prepare_index_directory
        indexer.index
      end

      # Generates all caches for this category.
      #
      def cache
        prepare_index_directory
        generate_caches
      end
      # We need to set what formatting method should be used.
      # Uses the one defined in the indexer.
      #
      def configure
        exact[:key_format] = self.key_format
        partial[:key_format] = self.key_format
      end
      def generate_caches
        configure
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