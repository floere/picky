module Query

  # Calculates bonuses and maluses for certain combinations.
  #
  class Heuristics
    
    #
    #
    def initialize bonuses, maluses = {}
      @weights_cache = {}
      @bonuses = prepare bonuses
      @maluses = prepare maluses
    end
    
    # Get the category indexes for the given bonuses.
    #
    def prepare bonuses
      bonuses
    end
    
    # Get the weight of an allocation.
    #
    # TODO Add a block to evaluate?
    #
    def weight_for clustered
      @bonuses[clustered] || 0
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
    # Just kidding. It's far more complicated than that ;)
    #
    include Helpers::Cache
    def score combinations
      # TODO Rewrite to use the category
      #
      categories = combinations.map { |combination| combination.bundle.category }.clustered_uniq
      
      # TODO Caching even necessary?
      #
      cached @weights_cache, categories do
        categories.map!(&:name)
        weight_for categories
      end
    end

  end
end