module Query
  # Base query class.
  #
  # Initialized with the index types it should search on.
  #
  class Base
    
    include Helpers::Measuring
    
    attr_writer   :tokenizer
    attr_accessor :reduce_to_amount, :weights
    
    # Run a query on the given text, with the offset and these indexes.
    #
    def initialize *index_types
      options      = Hash === index_types.last ? index_types.pop : {}
      @index_types = index_types
      @weigher     = Weigher.new index_types
      @tokenizer   = (options[:tokenizer]  || Tokenizers::Query.new)
      @weights     = (options[:weights] || Weights.new)
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
    def sorted_allocations tokens
      # Get the allocations.
      #
      allocations = @weigher.allocations_for tokens
      
      # Callbacks.
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
    # Override.
    #
    def identifiers_to_remove
      @identifiers_to_remove || @identifiers_to_remove = []
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