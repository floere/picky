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
      weights = index.facets category_identifier, options
      return weights unless filter_query = options[:filter]
      weights.select do |key, weight|
        search("#{filter_query} #{category_identifier}:#{key}", 0, 0).total > 0
      end
    end

  end

end
