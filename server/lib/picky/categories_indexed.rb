class Categories

  attr_reader :ignore_unassigned_tokens

  each_delegate :load_from_cache,
                :analyze,
                :to => :categories

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
    tokens = similar_tokens_for token
    inject_possible_for tokens
  end

  # Returns all possible similar tokens for the given token.
  #
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
    possible
  end

  # This returns the possible categories for this token.
  # If the user has already preselected a category for this token,
  # like "artist:moby", if not just return all for the given token,
  # since all are possible.
  #
  # Note: Once I thought this was called too often. But it is not (18.01.2011).
  #
  def possible_categories token
    token.user_defined_categories || categories
  end

  # # This returns the array of categories if the user has defined
  # # an existing category.
  # #
  # # Note: Returns nil if the user did not define one
  # #       or [] if he/she has defined a non-existing one.
  # #
  # def user_defined_categories token
  #   names = token.qualifiers
  #   names && names.map do |name|
  #     category_hash[name] # TODO Do this somewhere else? E.g. in the Indexes?
  #   end.compact
  # end

end