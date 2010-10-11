module Index
  
  # An index category holds a full and a partial index for a given field.
  #
  # For example an index category for names holds a full and
  # a partial index bundle for names.
  #
  class Category
    
    attr_reader :name, :type, :full, :partial
    
    #
    #
    def initialize name, type, options = {}
      @name = name
      @type = type
      
      partial    = options[:partial]    || Cacher::Partial::Default
      weights    = options[:weights]    || Cacher::Weights::Default
      similarity = options[:similarity] || Cacher::Similarity::Default
      
      @full    = options[:full_bundle]    || Bundle.new(:full,    self, type, Cacher::Partial::None.new, weights, similarity)
      @partial = options[:partial_bundle] || Bundle.new(:partial, self, type, partial, weights, Cacher::Similarity::None.new)
      
      @full    = options[:full_lambda].call(@full, @partial)    if options[:full_lambda]
      @partial = options[:partial_lambda].call(@full, @partial) if options[:partial_lambda]
    end
    
    # Loads the index from cache.
    #
    def load_from_cache
      full.load
      partial.load
    end
    
    def identifier
      "#{type.name}:#{name}"
    end
    
    # Generates all caches for this category.
    #
    def generate_caches
      timed_exclaim "Loading data from db for #{identifier}."
      generate_caches_from_db
      timed_exclaim "Generating partial for #{identifier}."
      generate_partial
      timed_exclaim "Generating caches from memory for #{identifier}."
      generate_caches_from_memory
      timed_exclaim "Dumping all caches for #{identifier}."
      dump_caches
    end
    def generate_caches_from_db
      full.generate_caches_from_db
    end
    def generate_partial
      partial.generate_partial_from full.index
    end
    def generate_caches_from_memory
      partial.generate_caches_from_memory
    end
    def dump_caches
      full.dump
      partial.dump
    end
    # TODO move to Kernel?
    #
    def timed_exclaim text
      exclaim "#{Time.now}: #{text}"
    end
    # TODO move to Kernel?
    #
    def exclaim text
      puts text
    end
    
    # Used for testing.
    #
    def generate_indexes_from_full_index
      generate_derived_full
      generate_partial
      generate_derived_partial
    end
    def generate_derived_full
      full.generate_derived
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
      token.partial? ? partial : full
    end

    #
    #
    def combination_for token
      weight(token) && ::Query::Combination.new(token, self)
    end

  end

end