module Picky

  class Search

    # Returns a list/hash of filtered facets.
    # 
    # Params
    #   category: The category whose facets to return.
    # 
    # Options
    #   counts: Whether you want counts (returns a Hash) or not (returns an Array). (Default true)
    #   at_least: A minimum count a facet needs to have (inclusive). (Default 1)
    #   filter: A query to filter the facets with(no_args).
    #
    # Usage:
    #   search.facets :name, filter: 'surname:peter', at_least: 2
    #
    def facets category_identifier, options = {}
      # TODO Make it work. How should it work with multiple indexes?
      #
      raise "#{__method__} cannot be used on searches with more than 1 index yet. Sorry!" if indexes.size > 1
      index = indexes.first
      
      # Get index-specific facet counts.
      #
      counts = index.facets category_identifier, options
      
      # We're done if there is no filter.
      #
      return counts unless filter_query = options[:filter]
      
      # Pre-tokenize query token category.
      #
      predefined_categories = [index[category_identifier]]
      
      # Pre-tokenize key token – replace text below.
      # Note: The original is not important.
      #
      # TODO Don't use predefined. Perhaps do:
      # key_token = Query::Token.new ''
      # key_token.predefined_categories = [index[category_identifier]]
      #
      empty = @symbol_keys ? :'' : ''
      key_token = Query::Token.new empty, nil, predefined_categories
      
      # Pre-tokenize filter for reuse.
      #
      tokenized_filter_query = tokenized filter_query, false
      tokenized_filter_query.tokens.push key_token
      
      # Extract options.
      #
      no_counts = options[:counts] == false
      minimal_counts = options[:at_least] || 1 # Default needs at least one.
      
      # Get actual counts.
      #
      if no_counts
        facets_without_counts counts, minimal_counts, tokenized_filter_query, options do |last_text|
          key_token.text = last_text # TODO Why is this necessary?
        end
      else
        facets_with_counts counts, minimal_counts, tokenized_filter_query, key_token.text, options do |last_text|
          key_token.text = last_text # TODO Why is this necessary?
        end
      end
    end
    def facets_without_counts counts, minimal_counts, tokenized_filter_query, last_token_text, options = {}
      counts.inject([]) do |result, (key, _)|
        # Replace only the key token text because that
        # is the only information that changes in between
        # queries.
        #
        # Note: DOes not use replace anymore.
        #
        yield key
        
        # Calculate up to 1000 facets using unique to show correct facet counts.
        # TODO Redesign and deoptimize the whole process.
        #
        total = search_with(tokenized_filter_query, 1000, 0, nil, true).total
        
        next result unless total >= minimal_counts
        result << key
      end
    end
    def facets_with_counts counts, minimal_counts, tokenized_filter_query, last_token_text, options = {}
      counts.inject({}) do |result, (key, _)|
        # Replace only the key token text because that
        # is the only information that changes in between
        # queries.
        #
        yield key
        
        # Calculate up to 1000 facets using unique to show correct facet counts.
        # TODO Redesign and deoptimize the whole process.
        #
        total = search_with(tokenized_filter_query, 1000, 0, nil, true).total
        
        next result unless total >= minimal_counts
        result[key] = total
        result
      end
    end

  end

end
