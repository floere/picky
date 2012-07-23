module Picky

  class Search

    # Returns a list of filtered facets.
    # 
    # Params
    #   category: The category whose facets to return.
    # 
    # Options
    #   more_than: A minimum weight a facet needs to have (exclusive). 
    #   filter: A query to filter the facets with.
    #
    # Usage:
    #   search.facets :name, filter: 'surname:peter', more_than: 0
    #
    def facets category_identifier, options = {}
      raise "#{__method__} cannot be used on searches with more than 1 index yet. Sorry!" if indexes.size > 1
      index = indexes.first
      
      # Get index-specific facet weights.
      #
      weights = index.facets category_identifier, options
      
      # We're done if there is no filter.
      #
      return weights unless filter_query = options[:filter]
      
      # Pre-tokenize filter for reuse.
      #
      tokenized_filter = tokenized filter_query, false
      
      # Filter out impossible facets.
      #
      weights.select do |key, weight|
        tokenized_query = tokenized "#{category_identifier}:#{key}"
        search_with(tokenized_filter + tokenized_query, 0, 0).total > 0
      end
    end

  end

end
