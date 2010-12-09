# = Picky Queries
#
# A Picky Query is an object which:
# * holds one or more indexes
# * offers an interface to query these indexes.
#
# You connect URL paths to indexes via a Query.
#
# We recommend not to use this directly, but connect it to an URL and query through one of these
# (Protip: Use "curl 'localhost:8080/query/path?query=exampletext')" in a Terminal.
#
# There are two flavors of queries:
# * Query::Full (Full results with all infos)
# * Query::Live (Same as the Full results without result ids. Useful for query result counters.)
#
module Query
  
  # The base query class.
  #
  # Not directly instantiated. However, its methods are used by its subclasses, Full and Live.
  #
  class Base
    
    include Helpers::Measuring
    
    attr_writer   :tokenizer
    attr_accessor :reduce_to_amount, :weights
    
    # Takes:
    # * A number of indexes
    # * Options hash (optional) with:
    #   * weigher:   A weigher. Query::Weigher by default.
    #   * tokenizer: Tokenizers::Query.default by default.
    #   * weights:   A hash of weights, or a Query::Weights object.
    #
    def initialize *index_type_definitions
      options      = Hash === index_type_definitions.last ? index_type_definitions.pop : {}
      indexes      = index_type_definitions.map &:indexed
      
      @weigher     = options[:weigher]   || Weigher.new(indexes)
      @tokenizer   = options[:tokenizer] || Tokenizers::Query.default
      weights      = options[:weights] || Weights.new
      @weights     = Hash === weights ? Weights.new(weights) : weights
    end
    
    # Search through this method.
    #
    # Parameters:
    # * text: The search text.
    # * offset = 0: _optional_ The offset from which position to return the ids. Useful for pagination.
    #
    # Note: The Routing uses this method after unravelling the HTTP request.
    #
    def search_with_text text, offset = 0
      search tokenized(text), offset
    end
    
    # Runs the actual search using Query::Tokens.
    #
    # Note: Internal method, use #search_with_text.
    #
    def search tokens, offset = 0
      results = nil
      
      duration = timed do
        results = execute(tokens, offset) || empty_results(offset) # TODO Does not work yet
      end
      results.duration = duration.round 6
      
      results
    end
    
    # Execute a search using Query::Tokens.
    #
    # Note: Internal method, use #search_with_text.
    #
    def execute tokens, offset
      results_from offset, sorted_allocations(tokens)
    end
    
    # Returns an empty result with default values.
    #
    # Parameters:
    # * offset = 0: _optional_ The offset to use for the empty results.
    #
    def empty_results offset = 0
      result_type.new offset
    end
    
    # Delegates the tokenizing to the query tokenizer.
    #
    # Parameters:
    # * text: The text to tokenize.
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
    def sorted_allocations tokens # :nodoc:
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
    def reduce allocations # :nodoc:
      allocations.reduce_to reduce_to_amount if reduce_to_amount
    end
    def remove_identifiers? # :nodoc:
      identifiers_to_remove.present?
    end
    def remove_from allocations # :nodoc:
      allocations.remove(identifiers_to_remove) if remove_identifiers?
    end
    # Override. TODO No, redesign.
    #
    def identifiers_to_remove # :nodoc:
      @identifiers_to_remove ||= []
    end
    
    # Packs the sorted allocations into results.
    #
    # This generates the id intersections. Lots of work going on.
    #
    # TODO Move to results. result_type.from allocations, offset
    #
    def results_from offset = 0, allocations = nil # :nodoc:
      results = result_type.new offset, allocations
      results.prepare!
      results
    end

  end
end