module Internals

  module Indexed

    class Categories

      attr_reader :categories, :category_hash, :ignore_unassigned_tokens

      each_delegate :load_from_cache,
                    :analyze,
                    :to => :categories

      # A list of indexed categories.
      #
      # Options:
      #  * ignore_unassigned_tokens: Ignore the given token if it cannot be matched to a category.
      #                              The default behaviour is that if a token does not match to
      #                              any category, the query will not return anything (since a
      #                              single token cannot be matched). If you set this option to
      #                              true, any token that cannot be matched to a category will be
      #                              simply ignored.
      #                              Use this if only a few matched words are important, like for
      #                              example of the query "Jonathan Myers 86455 Las Cucarachas"
      #                              you only want to match the zipcode, to have the search engine
      #                              display advertisements on the side for the zipcode.
      #                              Nifty! :)
      #
      def initialize options = {}
        clear

        @ignore_unassigned_tokens = options[:ignore_unassigned_tokens] || false
      end

      def to_s
        categories.indented_to_s
      end

      # Clears both the array of categories and the hash of categories.
      #
      def clear
        @categories    = []
        @category_hash = {}
      end

      # Add the given category to the list of categories.
      #
      def << category
        categories << category
        # Note: [category] is an optimization, since I need an array
        #       of categories.
        #       It's faster to just package it in an array on loading
        #       Picky than doing it over and over with each query.
        #
        category_hash[category.name] = [category]
      end

      # Return all possible combinations for the given token.
      #
      # This checks if it needs to also search through similar
      # tokens, if for example, the token is one with ~.
      # If yes, it puts together all solutions.
      #
      def possible_combinations_for token
        token.similar? ? similar_possible_for(token) : possible_for(token)
      end
      # Gets all similar tokens and puts together the possible combinations
      # for each found similar token.
      #
      def similar_possible_for token
        # Get as many tokens as necessary
        #
        tokens = similar_tokens_for token
        # possible combinations
        #
        inject_possible_for tokens
      end
      def similar_tokens_for token
        text = token.text
        categories.inject([]) do |result, category|
          next_token = token
          # Note: We could also break off here if not all the available
          #       similars are needed.
          #       Wait for a concrete case that needs this before taking
          #       action.
          #
          while next_token = next_token.next_similar_token(category)
            result << next_token if next_token && next_token.text != text
          end
          result
        end
      end
      def inject_possible_for tokens
        tokens.inject([]) do |result, token|
          possible = possible_categories token
          result + possible_for(token, possible)
        end
      end

      # Returns possible Combinations for the token.
      #
      # Note: The preselected_categories param is an optimization.
      #
      # Note: Returns [] if no categories matched (will produce no result).
      #       Returns nil if this token needs to be removed from the query.
      #       (Also none of the categories matched, but the ignore unassigned
      #       tokens option is true)
      #
      def possible_for token, preselected_categories = nil
        possible = (preselected_categories || possible_categories(token)).inject([]) do |combinations, category|
          combination = category.combination_for token
          combination ? combinations << combination : combinations
        end
        # This is an optimization to mark tokens that are ignored.
        #
        return if ignore_unassigned_tokens && possible.empty?
        possible # wrap in combinations
      end
      # This returns the possible categories for this token.
      # If the user has already preselected a category for this token,
      # like "artist:moby", if not just return all for the given token,
      # since all are possible.
      #
      # Note: Once I thought this was called too often. But it is not (18.01.2011).
      #
      def possible_categories token
        user_defined_categories(token) || categories
      end
      # This returns the array of categories if the user has defined
      # an existing category.
      #
      # Note: Returns nil if the user did not define one
      #       or if he/she has defined a non-existing one.
      #
      def user_defined_categories token
        category_hash[token.user_defined_category_name]
      end

    end

  end

end