module Picky

  class Search

    # Returns a list of filtered facets.
    # 
    # Params
    #   category: The category whose facets to return.
    #   filter_query: (optional) A query to filter the facets with.
    #
    # Usage:
    #   search.facets :name, 'surname:peter'
    #
    def facets category_identifier, filter_query = nil
      raise "#{__method__} cannot be used on searches with more than 1 index yet. Sorry!" if indexes.size > 1
      index = indexes.first
      weights = index.facets category_identifier
      return weights unless filter_query
      weights.select do |key, weight|
        search("#{filter_query} #{category_identifier}:#{key}", 0, 0).total > 0
      end
    end

  end

end
