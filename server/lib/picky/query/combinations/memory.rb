module Query

  # Combinations are a number of Combination-s.
  #
  # They are the core of an allocation.
  # An allocation consists of a number of combinations.
  #
  module Combinations # :nodoc:all

    # Memory Combinations contain specific methods for
    # calculating score and ids in memory.
    #
    class Memory < Base

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
      # Note: In the memory based version we ignore the (amount) needed hint.
      #       We cannot use the information to speed up the algorithm, unfortunately.
      #
      def ids _, _
        return [] if @combinations.empty?

        # Get the ids for each combination.
        #
        id_arrays = @combinations.inject([]) do |total, combination|
          total << combination.ids
        end

        # Call the optimized C algorithm.
        #
        # Note: It orders the passed arrays by size.
        #
        Performant::Array.memory_efficient_intersect id_arrays
      end

    end

  end

end