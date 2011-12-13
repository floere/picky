module Picky

  module Backends

    #
    #
    class Backend

      def reset bundle
       [
         create_inverted(bundle),
         create_weights(bundle),
         create_similarity(bundle),
         create_configuration(bundle),
         create_realtime(bundle)
        ]
      end

      # Returns the total score of the combinations.
      #
      # Default implementation. Override to speed up.
      #
      def weight combinations
        combinations.score
      end

      # Returns the result ids for the allocation.
      #
      # Sorts the ids by size and & through them in the following order (sizes):
      # 0. [100_000, 400, 30, 2]
      # 1. [2, 30, 400, 100_000]
      # 2. (100_000 & (400 & (30 & 2))) # => result
      #
      # Note: Uses a C-optimized intersection routine (in performant.c)
      #       for speed and memory efficiency.
      #
      # Note: In the memory based version we ignore the amount and
      # offset hints.
      # We cannot use the information to speed up the algorithm,
      # unfortunately.
      #
      def ids combinations, _, _
        # Get the ids for each combination.
        #
        id_arrays = combinations.inject([]) do |total, combination|
          total << combination.ids
        end

        # Call the optimized C algorithm.
        #
        # Note: It orders the passed arrays by size.
        #
        Performant::Array.memory_efficient_intersect id_arrays
      end

      #
      #
      def to_s
        self.class.name
      end

    end

  end

end