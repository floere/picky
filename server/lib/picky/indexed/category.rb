module Indexed
  
  # An index category holds a exact and a partial index for a given field.
  #
  # For example an index category for names holds a exact and
  # a partial index bundle for names.
  #
  class Category
    
    attr_reader :name, :index, :exact, :partial
    
    #
    #
    def initialize name, index, options = {}
      @name  = name
      @index = index
      
      similarity = options[:similarity] || Cacher::Similarity::Default
      
      @exact   = options[:exact_index_bundle]   || Bundle.new(:exact,   self, index, similarity)
      @partial = options[:partial_index_bundle] || Bundle.new(:partial, self, index, similarity)
      
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
    def load_from_cache
      timed_exclaim "Loading index #{identifier}."
      exact.load
      partial.load
    end
    
    # TODO Move to initializer?
    #
    def identifier
      @identifier ||= "#{index.name} #{name}"
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