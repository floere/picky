module Indexing # :nodoc:all

  # A Bundle is a number of indexes
  # per [index, category] combination.
  #
  # At most, there are three indexes:
  # * *core* index (always used)
  # * *weights* index (always used)
  # * *similarity* index (used with similarity)
  #
  # In Picky, indexing is separated from the index
  # handling itself through a parallel structure.
  #
  # Both use methods provided by this base class, but
  # have very different goals:
  #
  # * *Indexing*::*Bundle* is just concerned with creating index files
  #   and providing helper functions to e.g. check the indexes.
  #
  # * *Index*::*Bundle* is concerned with loading these index files into
  #   memory and looking up search data as fast as possible.
  #
  module Bundle

    # This is the indexing bundle.
    #
    # It does all menial tasks that have nothing to do
    # with the actual index running etc.
    #
    class Base < ::Bundle

      attr_accessor :partial_strategy,
                    :weights_strategy

      def initialize name, category, weights_strategy, partial_strategy, similarity_strategy, options = {}
        super name, category, similarity_strategy, options

        @weights_strategy = weights_strategy
        @partial_strategy = partial_strategy
        @key_format       = options[:key_format]
      end

      # Sets up a piece of the index for the given token.
      #
      def initialize_inverted_index_for token
        self.inverted[token] ||= []
      end

      # Generation
      #

      # This method
      # * Loads the base index from the "prepared..." file.
      # * Generates derived indexes.
      # * Dumps all the indexes into files.
      #
      def generate_caches_from_source
        load_from_prepared_index_file
        generate_caches_from_memory
      end
      # Generates derived indexes from the index and dumps.
      #
      # Note: assumes that there is something in the index
      #
      def generate_caches_from_memory
        cache_from_memory_generation_message
        generate_derived
      end
      def cache_from_memory_generation_message
        timed_exclaim %Q{"#{identifier}": Caching from intermediate in-memory index.}
      end

      # Generates the weights and similarity from the main index.
      #
      def generate_derived
        generate_weights
        generate_similarity
      end

      # Load the data from the db.
      #
      def load_from_prepared_index_file
        load_from_prepared_index_generation_message
        clear
        retrieve
      end
      def load_from_prepared_index_generation_message
        timed_exclaim %Q{"#{identifier}": Loading prepared data into memory.}
      end
      # Retrieves the prepared index data into the index.
      #
      # This is in preparation for generating
      # derived indexes (like weights, similarity)
      # and later dumping the optimized index.
      #
      def retrieve
        format = category.key_format || :to_i # Optimization.
        files.retrieve do |id, token|
          initialize_inverted_index_for token
          self.inverted[token] << id.send(format)
        end
      end

      # Generates a new index (writes its index) using the
      # partial caching strategy of this bundle.
      #
      def generate_partial
        generator = Generators::PartialGenerator.new self.inverted
        self.inverted = generator.generate self.partial_strategy
      end
      # Generate a partial index from the given exact inverted index.
      #
      def generate_partial_from exact_inverted_index
        timed_exclaim %Q{"#{identifier}": Generating partial index for index.}
        self.inverted = exact_inverted_index
        self.generate_partial
        self
      end
      # Generates a new weights index (writes its index) using the
      # given weight caching strategy.
      #
      def generate_weights
        generator = Generators::WeightsGenerator.new self.inverted
        self.weights = generator.generate self.weights_strategy
      end
      # Generates a new similarity index (writes its index) using the
      # given similarity caching strategy.
      #
      def generate_similarity
        generator = Generators::SimilarityGenerator.new self.inverted
        self.similarity = generator.generate self.similarity_strategy
      end

      # Saves the indexes in a dump file.
      #
      def dump
        timed_exclaim %Q{"#{identifier}": Dumping data.}
        dump_inverted
        dump_similarity
        dump_weights
        dump_configuration
      end
      # Dumps the core index.
      #
      def dump_inverted
        # timed_exclaim %Q{"#{identifier}": Dumping inverted index.}
        backend.dump_inverted self.inverted
      end
      # Dumps the weights index.
      #
      def dump_weights
        # timed_exclaim %Q{"#{identifier}": Dumping index weights.}
        backend.dump_weights self.weights
      end
      # Dumps the similarity index.
      #
      def dump_similarity
        # timed_exclaim %Q{"#{identifier}": Dumping similarity index.}
        backend.dump_similarity self.similarity
      end
      # Dumps the similarity index.
      #
      def dump_configuration
        # timed_exclaim %Q{"#{identifier}": Dumping configuration.}
        backend.dump_configuration self.configuration
      end

      # Alerts the user if an index is missing.
      #
      def raise_unless_cache_exists
        raise_unless_index_exists
        raise_unless_similarity_exists
      end
      # Alerts the user if one of the necessary indexes
      # (core, weights) is missing.
      #
      def raise_unless_index_exists
        if partial_strategy.saved?
          warn_if_index_small
          raise_unless_index_ok
        end
      end
      # Alerts the user if the similarity
      # index is missing (given that it's used).
      #
      def raise_unless_similarity_exists
        if similarity_strategy.saved?
          warn_if_similarity_small
          raise_unless_similarity_ok
        end
      end

      # Outputs a warning for the given cache.
      #
      def warn_cache_small what
        warn "Warning: #{what} cache for #{identifier} smaller than 16 bytes."
      end
      # Raises an appropriate error message for the given cache.
      #
      def raise_cache_missing what
        raise "Error: The #{what} cache for #{identifier} is missing."
      end

      # Warns the user if the similarity index is small.
      #
      def warn_if_similarity_small
        warn_cache_small :similarity if backend.similarity_cache_small?
      end
      # Alerts the user if the similarity index is not there.
      #
      def raise_unless_similarity_ok
        raise_cache_missing :similarity unless backend.similarity_cache_ok?
      end

      # Warns the user if the core or weights indexes are small.
      #
      def warn_if_index_small
        warn_cache_small :inverted if backend.inverted_cache_small?
        warn_cache_small :weights  if backend.weights_cache_small?
      end
      # Alerts the user if the core or weights indexes are not there.
      #
      def raise_unless_index_ok
        raise_cache_missing :inverted unless backend.inverted_cache_ok?
        raise_cache_missing :weights  unless backend.weights_cache_ok?
      end

    end

  end

end