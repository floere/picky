module Query

  # Calculates weights for certain combinations.
  #
  class Weights
    
    #
    #
    def initialize weights = {}
      @weights_cache = {}
      @weights = prepare weights
    end
    
    # Get the category indexes for the given bonuses.
    #
    def prepare weights
      weights
    end
    
    # Get the weight of an allocation.
    #
    def weight_for clustered
      @weights[clustered] || 0
    end
    
    # Returns an energy term E for allocation. this turns into a probability
    # by P(allocation) = 1/Z * exp (-1/T * E(allocation)),
    # where Z is the normalizing partition function
    # sum_allocations exp(-1/T *E(allocation)), and T is a temperature constant.
    # If T is high the distribution will be close to equally distributed.
    # If T is low, the distribution will be the indicator function
    # for min (E(allocation))…
    #
    # ...
    #
    # Just kidding. It's far more complicated than that. Ha ha ha ha ;)
    #
    # Note: Cache this if more complicated weighings become necessary.
    #
    def score combinations
      # TODO Beautify?
      #
      # weight_for combinations.map(&:category).clustered_uniq_fast.map!(&:name)
      weight_for combinations.map(&:category_name).clustered_uniq_fast
    end
    
  end
end