module Indexed
  
  # An index category holds a exact and a partial index for a given category.
  #
  # For example an index category for names holds a exact and
  # a partial index bundle for names.
  #
  class Category
    
    attr_accessor :exact
    attr_reader   :identifier, :name
    attr_writer   :partial
    
    #
    #
    def initialize name, index, options = {}
      @name = name
      
      configuration = Configuration::Index.new index, self
      
      @identifier    = configuration.identifier
      
      # TODO Push the defaults out into the index.
      #
      @partial_strategy = options[:partial] || Cacher::Partial::Default
      similarity = options[:similarity] || Cacher::Similarity::Default
      
      @exact   = options[:exact_index_bundle]   || Bundle.new(:exact,   configuration, similarity)
      @partial = options[:partial_index_bundle] || Bundle.new(:partial, configuration, similarity)
      
      @exact   = exact_lambda.call(@exact, @partial)   if exact_lambda   = options[:exact_lambda]
      @partial = partial_lambda.call(@exact, @partial) if partial_lambda = options[:partial_lambda]
      
      # TODO Extract?
      #
      Query::Qualifiers.add(configuration.category_name, generate_qualifiers_from(options) || [name])
    end
    
    # TODO Move to Index.
    #
    def generate_qualifiers_from options
      options[:qualifiers] || options[:qualifier] && [options[:qualifier]]
    end
    
    # Loads the index from cache.
    #
    def load_from_cache
      timed_exclaim "Loading index #{identifier}."
      exact.load
      partial.load
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
      token.partial?? partial : exact
    end
    
    # The partial strategy defines whether to really use the partial index.
    #
    def partial
      @partial_strategy.use_exact_for_partial?? @exact : @partial
    end
    
    #
    #
    def combination_for token
      weight(token) && ::Query::Combination.new(token, self)
    end
    
  end
  
end