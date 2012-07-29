module Picky

  class Index
    
    # Return facets for a category in the form:
    #   { text => count }
    #
    # Options
    #   counts: Whether you want counts or not.
    #   at_least: A minimum count a facet needs to have (inclusive). 
    #
    # TODO Think about having a separate index for counts to reduce the complexity of this.
    #
    def facets category_identifier, options = {}
      text_ids = self[category_identifier].exact.inverted
      no_counts = options[:counts] == false
      minimal_counts = options[:at_least]
      text_ids.inject(no_counts ? [] : {}) do |result, (text, ids)|
        size = ids.size
        next result if minimal_counts && size < minimal_counts
        if no_counts
          result << text
        else
          result[text] = size; result
        end
      end
    end

  end

end
