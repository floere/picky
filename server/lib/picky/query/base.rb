module Query
  # Base query class.
  #
  # Initialized with the index types it should search on.
  #
  class Base
    
    include Helpers::Measuring
    
    attr_writer   :tokenizer
    attr_accessor :reduce_to_amount, :weights
    
    # Takes:
    #  * A number of indexes
    #  * Options hash (optional) with:
    #    * weigher:   A weigher. Query::Weigher by default.
    #    * tokenizer: Tokenizers::Query.default by default.
    #    * weights:   A hash of weights, or a Query::Weights object.
    #
    def initialize *index_type_definitions
      options      = Hash === index_type_definitions.last ? index_type_definitions.pop : {}
      indexes      = index_type_definitions.map &:index
      
      @weigher     = options[:weigher]   || Weigher.new(indexes)
      @tokenizer   = options[:tokenizer] || Tokenizers::Query.default
      weights      = options[:weights] || Weights.new
      @weights     = Hash === weights ? Weights.new(weights) : weights
    end
    
    # Convenience method.
    #
    def search_with_text text, offset = 0
      search tokenized(text), offset
    end
    
    # This runs the actual search.
    #
    def search tokens, offset = 0
      results = nil
      
      duration = timed do
        results = execute(tokens, offset) || empty_results(offset) # TODO Does not work yet
      end
      results.duration = duration.round 6
      
      results
    end
    
    # Return nil if no results have been found.
    #
    def execute tokens, offset
      results_from offset, sorted_allocations(tokens)
    end
    
    # Returns an empty result with default values.
    #
    def empty_results offset = 0
      result_type.new offset
    end
    
    # Delegates the tokenizing to the query tokenizer.
    #
    def tokenized text
      @tokenizer.tokenize text
    end
    
    # Gets sorted allocations for the tokens.
    #
    # This generates the possible allocations, sorted.
    #
    # TODO Smallify.
    #
    # TODO Rename: allocations
    #
    def sorted_allocations tokens
      # Get the allocations.
      #
      # TODO Pass in reduce_to_amount (aka max_allocations)
      #
      # TODO uniq, score, sort in there
      #
      allocations = @weigher.allocations_for tokens
      
      # Callbacks.
      #
      # TODO Reduce before sort?
      #
      reduce allocations
      remove_from allocations
      
      # Remove double allocations.
      #
      allocations.uniq
      
      # Score the allocations using weights as bias.
      #
      allocations.calculate_score weights
      
      # Sort the allocations.
      # (allocations are sorted according to score, highest to lowest)
      #
      allocations.sort
      
      # Return the allocations.
      #
      allocations
    end
    def reduce allocations
      allocations.reduce_to reduce_to_amount if reduce_to_amount
    end
    def remove_identifiers?
      identifiers_to_remove.present?
    end
    def remove_from allocations
      allocations.remove(identifiers_to_remove) if remove_identifiers?
    end
    # Override. TODO No, redesign.
    #
    def identifiers_to_remove
      @identifiers_to_remove ||= []
    end
    
    # Packs the sorted allocations into results.
    #
    # This generates the id intersections. Lots of work going on.
    #
    # TODO Move to results. result_type.from allocations, offset
    #
    def results_from offset = 0, allocations = nil
      results = result_type.new offset, allocations
      results.prepare!
      results
    end

  end
end