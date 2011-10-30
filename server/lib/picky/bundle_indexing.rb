module Picky

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
  # This is the indexing bundle.
  #
  # It does all menial tasks that have nothing to do
  # with the actual index running etc.
  # (Find these in Indexed::Bundle)
  #
  class Bundle

    attr_reader :backend,
                :prepared

    # When indexing, clear only clears the inverted index.
    #
    delegate :clear, :to => :inverted

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

    # "Empties" the index(es) by getting a new empty
    # internal backend instance.
    #
    def empty
      empty_inverted
      empty_configuration
    end
    def empty_inverted
      @inverted = @backend_inverted.empty
    end
    def empty_configuration
      @configuration = @backend_configuration.empty
    end

    # Load the data from the db.
    #
    def load_from_prepared_index_file
      load_from_prepared_index_generation_message
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
    # TODO Move this out to the category?
    #
    def retrieve
      format = key_format || :to_i
      empty_inverted
      prepared.retrieve do |id, token|
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
      @backend_inverted.dump self.inverted
    end
    # Dumps the weights index.
    #
    def dump_weights
      @backend_weights.dump self.weights
    end
    # Dumps the similarity index.
    #
    def dump_similarity
      @backend_similarity.dump self.similarity
    end
    # Dumps the similarity index.
    #
    def dump_configuration
      @backend_configuration.dump self.configuration
    end

  end

end