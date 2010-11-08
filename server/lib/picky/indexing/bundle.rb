# encoding: utf-8
#
module Indexing

  # This is the indexing bundle.
  # It does all menial tasks that have nothing to do
  # with the actual index running etc.
  #
  # TODO Superclass?
  #
  class Bundle < ::Bundle
    
    attr_accessor :partial_strategy, :weights_strategy
    attr_reader   :files
    
    # Path is in which directory the cache is located.
    #
    def initialize name, category, type, similarity_strategy, partial_strategy, weights_strategy
      super name, category, type, similarity_strategy
      
      @partial_strategy    = partial_strategy
      @weights_strategy    = weights_strategy
    end
    
    # Generation
    #
    
    # This method
    # * loads the base index from the db
    # * generates derived indexes
    # * dumps all the indexes into files
    #
    def generate_caches_from_source
      load_from_index_file
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
      timed_exclaim "CACHE FROM MEMORY #{identifier}."
    end
    
    # Generates the weights and similarity from the main index.
    #
    def generate_derived
      generate_weights
      generate_similarity
    end
    
    # Load the data from the db.
    #
    def load_from_index_file
      load_from_index_generation_message
      clear
      retrieve
    end
    def load_from_index_generation_message
      timed_exclaim "LOAD INDEX #{identifier}."
    end
    # Retrieves the data into the index.
    #
    def retrieve
      files.retrieve do |id, token|
        initialize_index_for token
        index[token] << id
      end
    end
    def initialize_index_for token
      index[token] ||= []
    end
    
    # Generators.
    #
    # TODO Move somewhere more fitting.
    #
    
    # Generates a new index (writes its index) using the
    # given partial caching strategy.
    #
    def generate_partial
      generator = Cacher::PartialGenerator.new self.index
      self.index = generator.generate self.partial_strategy
    end
    def generate_partial_from exact_index
      timed_exclaim "PARTIAL GENERATE #{identifier}."
      self.index = exact_index
      self.generate_partial
      self
    end
    # Generates a new similarity index (writes its index) using the
    # given similarity caching strategy.
    #
    def generate_similarity
      generator = Cacher::SimilarityGenerator.new self.index
      self.similarity = generator.generate self.similarity_strategy
    end
    # Generates a new weights index (writes its index) using the
    # given weight caching strategy.
    #
    def generate_weights
      generator = Cacher::WeightsGenerator.new self.index
      self.weights = generator.generate self.weights_strategy
    end

    # Saves the index in a dump file.
    #
    def dump
      dump_index
      dump_similarity
      dump_weights
    end
    def dump_index
      timed_exclaim "DUMP INDEX #{identifier}."
      files.dump_index index
    end
    def dump_similarity
      timed_exclaim "DUMP SIMILARITY #{identifier}."
      files.dump_similarity similarity
    end
    def dump_weights
      timed_exclaim "DUMP WEIGHTS #{identifier}."
      files.dump_weights weights
    end
    
    # Alerts the user if an index is missing.
    #
    def raise_unless_cache_exists
      warn_cache_small :index      if files.index_cache_small?
      warn_cache_small :similarity if files.similarity_cache_small?
      warn_cache_small :weights    if files.weights_cache_small?

      raise_cache_missing :index      unless files.index_cache_ok?
      raise_cache_missing :similarity unless files.similarity_cache_ok?
      raise_cache_missing :weights    unless files.weights_cache_ok?
    end
    def warn_cache_small what
      puts "#{what} cache for #{identifier} smaller than 16 bytes."
    end
    # Raises an appropriate error message.
    #
    def raise_cache_missing what
      raise "#{what} cache for #{identifier} missing."
    end
    
  end
end