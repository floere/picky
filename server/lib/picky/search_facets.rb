module Picky

  class Search

    # Returns a list/hash of filtered facets.
    # 
    # Params
    #   category: The category whose facets to return.
    # 
    # Options
    #   counts: Whether you want counts (returns a Hash) or not (returns an Array).
    #   at_least: A minimum count a facet needs to have (inclusive). 
    #   filter: A query to filter the facets with.
    #
    # Usage:
    #   search.facets :name, filter: 'surname:peter', more_than: 0
    #
    def facets category_identifier, options = {}
      raise "#{__method__} cannot be used on searches with more than 1 index yet. Sorry!" if indexes.size > 1
      index = indexes.first
      
      # Get index-specific facet counts.
      #
      counts = index.facets category_identifier, options
      
      # We're done if there is no filter.
      #
      return counts unless filter_query = options[:filter]
      
      # Pre-tokenize filter for reuse.
      #
      tokenized_filter = tokenized filter_query, false
      
      # Pre-tokenize query token category.
      #
      predefined_categories = [index[category_identifier]]
      
      # Extract options.
      #
      no_counts = options[:counts] == false
      minimal_counts = options[:at_least] || 1 # Default needs at least one.
      
      # Get actual counts.
      #
      counts.inject(no_counts ? [] : {}) do |result, (key, _)|
        # TODO Rewrite this.
        #
        tokenized_query = Query::Tokens.new(
          [Query::Token.new(key, key, predefined_categories)]
        )
        # tokenized_query = tokenized "#{category_identifier}:#{key}", false
        total = search_with(tokenized_filter + tokenized_query, 0, 0).total
        next result unless total >= minimal_counts
        if no_counts
          result << key
        else
          result[key] = total; result
        end
      end
    end

  end

end
