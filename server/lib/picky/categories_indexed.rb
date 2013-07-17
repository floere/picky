module Picky

  class Categories

    each_forward :load,
                 :analyze,
                 :to => :categories

    # Gets all similar tokens and puts together the possible combinations
    # for each found similar token.
    #
    def similar_possible_for token
      tokens = similar_tokens_for token
      inject_possible_for tokens
    end

    # Returns all possible similar tokens for the given token.
    #
    def similar_tokens_for token
      categories.inject([]) do |result, category|
        result + token.similar_tokens_for(category)
      end
    end

    #
    #
    def inject_possible_for tokens
      tokens.inject([]) do |result, token|
        possible = possible_categories token
        result + possible_for(token, possible)
      end
    end

    # Returns possible Combinations for the token.
    #
    # Note: The preselected_categories param is an optimization.
    # Note: Returns [] if no categories matched (will produce no result).
    #
    def possible_for token, preselected_categories = nil
      (preselected_categories || possible_categories(token)).inject([]) do |combinations, category|
        combination = token.combination_for category
        combination ? combinations << combination : combinations
      end
    end

    # This returns the possible categories for this token.
    # If the user has already preselected a category for this token,
    # like "artist:moby", if not just return all for the given token,
    # since all are possible.
    #
    # Note: Once I thought this was called too often. But it is not (18.01.2011).
    #
    def possible_categories token
      token.predefined_categories(qualifier_mapper) || categories
    end

  end

end