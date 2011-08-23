# encoding: utf-8
#
module Picky

  # = Picky Searches
  #
  # A Picky Search is an object which:
  #  * holds one or more indexes
  #  * offers an interface to query these indexes.
  #
  # You connect URL paths to indexes via a Query.
  #
  # We recommend to not use this directly, but connect it to an URL and query through one of these
  # (Protip: Use "curl 'localhost:8080/query/path?query=exampletext')" in a Terminal.
  #
  class Search

    include Helpers::Measuring

    attr_reader   :indexes
    attr_accessor :tokenizer, :weights

    # Takes:
    # * A number of indexes
    #
    # TODO Add identifiers_to_remove (rename) and reduce_allocations_to_amount (rename).
    # TODO categories_to_remove ?
    #
    # It is also possible to define the tokenizer and weights like so.
    # Example:
    #   search = Search.new(index1, index2, index3) do
    #     searching removes_characters: /[^a-z]/, etc.
    #     weights [:author, :title] => +3, [:title, :isbn] => +1
    #   end
    #
    def initialize *index_definitions
      @indexes = Query::Indexes.new *index_definitions, combinations_type_for(index_definitions)

      instance_eval(&Proc.new) if block_given?

      @tokenizer ||= Tokenizers::Query.default
      @weights   ||= Query::Weights.new

      self
    end

    # Examples:
    #   search = Search.new(index1, index2, index3) do
    #     searching removes_characters: /[^a-z]/,
    #               # etc.
    #   end
    #
    #   search = Search.new(index1, index2, index3) do
    #     searching MyTokenizerThatRespondsToTheMethodTokenize.new
    #   end
    #
    def searching options
      @tokenizer = if options.respond_to?(:tokenize)
        options
      else
        options && Tokenizers::Query.new(options)
      end
    end

    # Example:
    #   search = Search.new(books_index, dvd_index, mp3_index) do
    #     boost [:author, :title] => +3,
    #           [:title, :isbn]   => +1
    #   end
    #
    def boost weights
      weights  ||= Query::Weights.new
      @weights = Hash === weights ? Query::Weights.new(weights) : weights
    end

    # This is the main entry point for a query.
    # Use this in specs and also for running queries.
    #
    # Parameters:
    # * text: The search text.
    # * ids = 20: _optional_ The amount of ids to calculate (with offset).
    # * offset = 0: _optional_ The offset from which position to return the ids. Useful for pagination.
    #
    # Note: The Rack adapter calls this method after unravelling the HTTP request.
    #
    def search text, ids = 20, offset = 0
      search_with tokenized(text), ids.to_i, offset.to_i, text
    end

    # Runs the actual search using Query::Tokens.
    #
    # Note: Internal method, use #search
    #
    def search_with tokens, ids = 20, offset = 0, original_text = nil
      results = nil

      duration = timed do
        results = execute tokens, ids, offset, original_text
      end
      results.duration = duration.round 6

      results
    end

    # Execute a search using Query::Tokens.
    #
    # Note: Internal method, use #search.
    #
    def execute tokens, ids, offset, original_text = nil
      Results.from original_text, ids, offset, sorted_allocations(tokens)
    end

    # Delegates the tokenizing to the query tokenizer.
    #
    # Parameters:
    # * text: The text to tokenize.
    #
    def tokenized text
      tokens, originals = tokenizer.tokenize text
      tokens = Query::Tokens.processed tokens, originals
      tokens.partialize_last # Set certain tokens as partial.
      tokens
    end

    # Gets sorted allocations for the tokens.
    #
    def sorted_allocations tokens # :nodoc:
      indexes.prepared_allocations_for tokens, weights
    end

    # Returns the right combinations strategy for
    # a number of query indexes.
    #
    # Currently it isn't possible using Memory and Redis etc.
    # indexes in the same query index group.
    #
    # Picky will raise a Query::Indexes::DifferentTypesError.
    #
    @@mapping = {
      Indexes::Memory => Query::Combinations::Memory,
      Indexes::Redis  => Query::Combinations::Redis
    }
    def combinations_type_for index_definitions_ary
      index_types = extract_index_types index_definitions_ary
      !index_types.empty? && @@mapping[*index_types] || Query::Combinations::Memory
    end
    def extract_index_types index_definitions_ary
      index_types = index_definitions_ary.map(&:class)
      index_types.uniq!
      check_index_types index_types
      index_types
    end
    def check_index_types index_types
      raise_different index_types if index_types.size > 1
    end
    # Currently it isn't possible using Memory and Redis etc.
    # indexes in the same query index group.
    #
    class DifferentTypesError < StandardError
      def initialize types
        @types = types
      end
      def to_s
        "Currently it isn't possible to mix #{@types.join(" and ")} Indexes in the same Search instance."
      end
    end
    def raise_different index_types
      raise DifferentTypesError.new(index_types)
    end

    # Display some nice information for the user.
    #
    def to_s
      s = "#{self.class}("
      s << @indexes.indexes.map(&:name).join(', ')
      s << ", weights: #{@weights}" unless @weights.empty?
      s << ")"
      s
    end

  end

end