module Indexing
  
  class Category
    
    attr_reader :exact, :partial, :name, :configuration, :indexer
    
    def initialize name, index, options = {}
      @name = name
      
      # Now we have enough info to combine the index and the category.
      #
      @configuration = Configuration::Index.new index, self #, :as => options[:as] # TODO option as.
      
      @tokenizer = options[:tokenizer] || Tokenizers::Index.default
      @indexer = Indexers::Serial.new configuration, options[:source], @tokenizer
      
      # TODO Push into Bundle.
      #
      partial    = options[:partial]    || Cacher::Partial::Default
      weights    = options[:weights]    || Cacher::Weights::Default
      similarity = options[:similarity] || Cacher::Similarity::Default
      
      @exact   = options[:exact_indexing_bundle]   || Bundle.new(:exact,   configuration, similarity, Cacher::Partial::None.new, weights)
      @partial = options[:partial_indexing_bundle] || Bundle.new(:partial, configuration, Cacher::Similarity::None.new, partial, weights)
    end
    
    delegate :identifier, :prepare_index_directory, :to => :configuration
    delegate :source, :source=, :tokenizer, :tokenizer=, :to => :indexer
    
    # TODO Spec.
    #
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
      generate_caches
    end
    def generate_caches
      generate_caches_from_source
      generate_partial
      generate_caches_from_memory
      dump_caches
      timed_exclaim "CACHE FINISHED #{identifier}."
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