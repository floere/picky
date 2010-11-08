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
      
      @exact   = options[:exact_index_bundle]   || Bundle.new(:exact,   self, type)
      @partial = options[:partial_index_bundle] || Bundle.new(:partial, self, type)
      
      @exact   = exact_lambda.call(@exact, @partial)   if exact_lambda   = options[:exact_lambda]
      @partial = partial_lambda.call(@exact, @partial) if partial_lambda = options[:partial_lambda]
      
      # Extract?
      #
      qualifiers = generate_qualifiers_from options
      Query::Qualifiers.add(name, qualifiers) if qualifiers
    end
    
    # TODO Move to Index.
    #
    def generate_qualifiers_from options
      options[:qualifiers] || options[:qualifier] && [options[:qualifier]] || [name]
    end
    
    # Loads the index from cache.
    #
    # TODO Metaprogram delegation? each_delegate?
    #
    def load_from_cache
      timed_exclaim "Loading index #{identifier}."
      exact.load
      partial.load
    end
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
    def create_directory_structure
      timed_exclaim "Creating directory structure for #{identifier}."
      exact.create_directory
      partial.create_directory
    end
    
    # TODO Move to initializer?
    #
    def identifier
      @identifier ||= "#{type.name} #{name}"
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