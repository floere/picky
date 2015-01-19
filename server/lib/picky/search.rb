# encoding: utf-8
#
module Picky

  # = Picky Searches
  #
  # A Picky Search is an object which:
  # * holds one or more indexes
  # * offers an interface to query these indexes.
  #
  # Example:
  #   search = Picky::Search.new index1, index2
  #   search.search 'query'
  #
  class Search

    include API::Search::Boost

    include Helpers::Measuring

    attr_reader :indexes,
                :ignore_unassigned
    attr_accessor :tokenizer,
                  :boosts

    forward :remap_qualifiers,
            :to => :indexes

    # Takes:
    # * A number of indexes
    #
    # It is also possible to define the tokenizer and boosts like so.
    # Example:
    #   search = Search.new(index1, index2, index3) do
    #     searching removes_characters: /[^a-z]/ # etc.
    #     boosts [:author, :title] => +3,
    #            [:title, :isbn] => +1
    #   end
    #
    def initialize *indexes
      @indexes = Query::Indexes.new *indexes

      instance_eval(&Proc.new) if block_given?

      @tokenizer ||= Tokenizer.searching # THINK Not dynamic. Ok?
      @boosts    ||= Query::Boosts.new

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
      @tokenizer = if options.respond_to? :tokenize
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
    def max_allocations amount = nil
      amount ? @max_allocations = amount : @max_allocations
    end

    # Tells Picky to terminate calculating ids if it has enough ids.
    # (So, early)
    #
    # Important note: Do not use this for the live search!
    # (As Picky needs to calculate the total)
    #
    # Note: When using the Picky interface, do not terminate too
    # early as this will kill off the allocation selections.
    # A value of
    #    terminate_early 5
    # is probably a good idea to show the user 5 extra
    # beyond the needed ones.
    #
    # Examples:
    #   # Terminate if you have enough ids.
    #   #
    #   search = Search.new(index1, index2, index3) do
    #     terminate_early
    #   end
    #
    #   # After calculating enough ids,
    #   # calculate 5 extra allocations for the interface.
    #   #
    #   search = Search.new(index1, index2, index3) do
    #     terminate_early 5
    #   end
    #
    def terminate_early extra_allocations = 0
      @extra_allocations = extra_allocations.respond_to?(:to_hash) ? extra_allocations[:with_extra_allocations] : extra_allocations
    end

    # Examples:
    #   search = Search.new(books_index, dvd_index, mp3_index) do
    #     boost [:author, :title] => +3,
    #           [:title, :isbn]   => +1
    #   end
    #
    # or
    #
    #   # Explicitly add a random number (0...1) to the boosts.
    #   #
    #   my_boosts = Class.new do
    #     # Instance only needs to implement
    #     #   boost_for combinations
    #     # and return a number that is
    #     # added to the score.
    #     #
    #     def boost_for combinations
    #       rand
    #     end
    #   end.new
    #
    #   search = Search.new(books_index, dvd_index, mp3_index) do
    #     boost my_boosts
    #   end
    #
    def boost boosts
      @boosts = extract_boosts boosts
    end
    
    def symbol_keys
      @symbol_keys = true
    end

    # Ignore given categories and/or combinations of
    # categories.
    #
    # Example:
    #   search = Search.new(people) do
    #     ignore :name,
    #            :first_name
    #            [:last_name, :street]
    #   end
    #
    def ignore *allocations_and_categories
      allocations_and_categories.each do |allocation_or_category|
        if allocation_or_category.respond_to? :to_sym
          indexes.ignore_categories allocation_or_category
        else
          indexes.ignore_allocations allocation_or_category
        end
      end
    end

    # Exclusively keep combinations of
    # categories.
    #
    # Example:
    #   search = Search.new(people) do
    #     only [:last_name, :street],
    #          [:last_name, :first_name]
    #   end
    #
    def only *allocations_and_categories
      indexes.keep_allocations *allocations_and_categories
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
    #     ignore_unassigned_tokens
    #   end
    #
    # With this set (to true), if in "Peter Flunder", "Flunder"
    # couldn't be assigned to any category, it will simply be
    # ignored. This is done for each categorization.
    #
    def ignore_unassigned_tokens value = true
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
    # Options:
    # * unique: Whether to return unique ids.
    #
    # Note: The Rack adapter calls this method after unravelling the HTTP request.
    #
    def search text, ids = 20, offset = 0, options = {}
      search_with tokenized(text), ids.to_i, offset.to_i, text, options[:unique]
    end

    # Runs the actual search using Query::Tokens.
    #
    # Note: Internal method, use #search to search.
    #
    def search_with tokens, ids = 20, offset = 0, original_text = nil, unique = false
      results = nil

      duration = timed do
        results = execute tokens, ids, offset, original_text, unique
      end
      results.duration = duration.round 6

      results
    end

    # Execute a search using Query::Tokens.
    #
    # Note: Internal method, use #search to search.
    #
    def execute tokens, ids, offset, original_text = nil, unique = false
      Results.new original_text,
                  ids,
                  offset,
                  sorted_allocations(tokens, @max_allocations),
                  @extra_allocations,
                  unique
    end

    # Forwards the tokenizing to the query tokenizer.
    #
    # Parameters:
    # * text: The string to tokenize.
    # * partialize_last: Whether to partialize the last token.
    #
    # Note: By default, the last token is always partial.
    #
    # Returns:
    # * A Picky::Query::Tokens instance.
    #
    def tokenized text, partialize_last = true
      tokens, originals = tokenizer.tokenize text
      tokens = Query::Tokens.processed tokens, originals || tokens, @ignore_unassigned
      tokens.symbolize if @symbol_keys # SYMBOLS.
      tokens.partialize_last if partialize_last
      tokens
    end

    # Gets sorted allocations for the tokens.
    #
    # TODO Remove and just call prepared (and rename to sorted)?
    #
    def sorted_allocations tokens, amount = nil
      indexes.prepared_allocations_for tokens, boosts, amount
    end

    # Display some nice information for the user.
    #
    def to_s
      s = [
        (@indexes.indexes.map(&:name).join(', ') unless @indexes.indexes.empty?),
        ("boosts: #@boosts" if @boosts)
      ].compact
      "#{self.class}(#{s.join(', ')})"
    end

  end

end