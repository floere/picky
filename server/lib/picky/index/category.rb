module Index
  
  # An index category holds a exact and a partial index for a given field.
  #
  # For example an index category for names holds a exact and
  # a partial index bundle for names.
  #
  class Category
    
    attr_reader :name, :type, :exact, :partial
    
    #
    #
    def initialize name, type, options = {}
      @name = name
      @type = type
      
      partial    = options[:partial]    || Cacher::Partial::Default
      weights    = options[:weights]    || Cacher::Weights::Default
      similarity = options[:similarity] || Cacher::Similarity::Default
      
      @exact   = options[:exact_bundle]   || Bundle.new(:exact,   self, type, Cacher::Partial::None.new, weights, similarity)
      @partial = options[:partial_bundle] || Bundle.new(:partial, self, type, partial, weights, Cacher::Similarity::None.new)
      
      @exact   = exact_lambda.call(@exact, @partial)   if exact_lambda   = options[:exact_lambda]
      @partial = partial_lambda.call(@exact, @partial) if partial_lambda = options[:partial_lambda]
    end
    
    # Loads the index from cache.
    #
    def load_from_cache
      exact.load
      partial.load
    end
    
    def identifier
      "#{type.name} #{name}"
    end
    
    # Generates all caches for this category.
    #
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
    
    # Used for testing.
    #
    def generate_indexes_from_exact_index
      generate_derived_exact
      generate_partial
      generate_derived_partial
    end
    def generate_derived_exact
      exact.generate_derived
    end
    def generate_derived_partial
      partial.generate_derived
    end

    # Gets the weight for this token's text.
    #
    def weight token
      bundle_for(token).weight token.text
    end

    # Gets the ids for this token's text.
    #
    def ids token
      bundle_for(token).ids token.text
    end

    # Returns the right index bundle for this token.
    #
    def bundle_for token
      token.partial? ? partial : exact
    end

    #
    #
    def combination_for token
      weight(token) && ::Query::Combination.new(token, self)
    end

  end

end