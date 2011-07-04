module Query

  # Calculates weights for certain combinations.
  #
  class Weights # :nodoc:all

    attr_reader :weights

    #
    #
    def initialize weights = {}
      @weights = weights
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
      # TODO Or hide: combinations#to_weights_key (but it's an array, so…)
      #
      # TODO combinations could cluster uniq as combinations are added (since combinations don't change).
      #
      # TODO Or it could use actual combinations? Could it? Or make combinations comparable to Symbols.
      #
      weight_for combinations.map(&:category_name).clustered_uniq_fast
    end

    # Are there any weights defined?
    #
    def empty?
      @weights.empty?
    end

    def == other
      @weights == other.weights
    end

    # Prints out a nice representation of the configured weights.
    #
    def to_s
      @weights.to_s
    end

  end
end