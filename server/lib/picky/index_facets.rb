module Picky

  class Index
    
    # Return facets for a category in the form:
    #   { text => weight } # or ids.size?
    #
    def facets category_identifier
      self[category_identifier].exact.weights
    end

  end

end
