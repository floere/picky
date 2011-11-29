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
    attr_accessor :tokenizer,
                  :weights

    delegate :ignore,
             :to => :indexes

    # Takes:
    # * A number of indexes
    #
    # TODO Add reduce_allocations_to_amount (rename).
    #
    # It is also possible to define the tokenizer and weights like so.
    # Example:
    #   search = Search.new(index1, index2, index3) do
    #     searching removes_characters: /[^a-z]/ # etc.
    #     weights [:author, :title] => +3,
    #             [:title, :isbn] => +1
    #   end
    #
    def initialize *index_definitions
      @indexes = Query::Indexes.new *index_definitions

      instance_eval(&Proc.new) if block_given?

      @tokenizer ||= Tokenizer.query_default # THINK Not dynamic. Ok?
      @weights   ||= Query::Weights.new
      @ignore_unassigned = false if @ignore_unassigned.nil?

      self
    end

    # Defines tokenizer options or the tokenizer itself.
    #
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
        options && Tokenizer.new(options)
      end
    end

    # Sets the max amount of allocations to calculate.
    #
    # Examples:
    #   search = Search.new(index1, index2, index3) do
    #     max_allocations 10
    #   end
    #
    def max_allocations amount
      amount ? @max_allocations = amount : @max_allocations
    end

    # Examples:
    #   search = Search.new(books_index, dvd_index, mp3_index) do
    #     boost [:author, :title] => +3,
    #           [:title, :isbn]   => +1
    #   end
    #
    # or
    #
    #   # Explicitly add a random number (0...1) to the weights.
    #   #
    #   my_weights = Class.new do
    #     # Instance only needs to implement
    #     #   score_for combinations
    #     # and return a number that is
    #     # added to the weight.
    #     #
    #     def score_for combinations
    #       rand
    #     end
    #   end.new
    #
    #   search = Search.new(books_index, dvd_index, mp3_index) do
    #     boost my_weights
    #   end
    #
    def boost weights
      @weights = if weights.respond_to?(:score_for)
        weights
      else
        Query::Weights.new weights
      end
    end

    # Ignore the given token if it cannot be matched to a category.
    # The default behaviour is that if a token does not match to
    # any category, the query will not return anything (since a
    # single token cannot be matched). If you set this option to
    # true, any token that cannot be matched to a category will be
    # simply ignored.
    #
    # Use this if only a few matched words are important, like for
    # example of the query "Jonathan Myers 86455 Las Cucarachas"
    # you only want to match the zipcode, to have the search engine
    # display advertisements on the side for the zipcode.
    #
    # False by default.
    #
    # Example:
    #   search = Search.new(books_index, dvd_index, mp3_index) do
    #     ignore_unassigned_tokens true
    #   end
    #
    # With this set to true, if in "Peter Flunder", "Flunder"
    # couldn't be assigned to any category, it will simply be
    # ignored. This is done for each categorization.
    #
    def ignore_unassigned_tokens value
      @ignore_unassigned = value
    end

    # This is the main entry point for a query.
    # Use this in specs and also for running queries.
    #
    # Parameters:
    # * text:       The search text.
    # * ids = 20:   The amount of ids to calculate (with offset).
    # * offset = 0: The offset from which position to return the ids. Useful for pagination.
    #
    # Note: The Rack adapter calls this method after unravelling the HTTP request.
    #
    def search text, ids = 20, offset = 0
      search_with tokenized(text), ids.to_i, offset.to_i, text
    end

    # Runs the actual search using Query::Tokens.
    #
    # Note: Internal method, use #search to search.
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
    # Note: Internal method, use #search to search.
    #
    def execute tokens, ids, offset, original_text = nil
      Results.from original_text, ids, offset, sorted_allocations(tokens, @max_allocations)
    end

    # Delegates the tokenizing to the query tokenizer.
    #
    # Parameters:
    # * text: The string to tokenize.
    #
    # Returns:
    # * A Picky::Query::Tokens instance.
    #
    def tokenized text
      tokens, originals = tokenizer.tokenize text
      tokens = Query::Tokens.processed tokens, originals || tokens, @ignore_unassigned
      # tokens.symbolize # TODO Symbols.
      tokens.partialize_last # Note: In the standard Picky search, the last token is always partial.
      tokens
    end

    # Gets sorted allocations for the tokens.
    #
    def sorted_allocations tokens, amount = nil # :nodoc:
      indexes.prepared_allocations_for tokens, weights, amount
    end

    # Display some nice information for the user.
    #
    def to_s
      s = "#{self.class}("
      ary = []
      ary << @indexes.indexes.map(&:name).join(', ') unless @indexes.indexes.empty?
      ary << "weights: #{@weights}" if @weights
      s << ary.join(', ')
      s << ")"
      s
    end

  end

end