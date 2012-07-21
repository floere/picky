module Picky

  class Index
    
    # Return facets for a category in the form:
    #   { text => weight } # or ids.size?
    #
    def facets category_identifier, options = {}
      weights = self[category_identifier].exact.weights
      if minimal_weight = options[:more_than]
        weights.select { |_, weight| weight > minimal_weight }
      else
        weights
      end
    end

  end

end
