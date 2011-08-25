module Picky

  module Backends

    class Memory < Backend

      def create_inverted bundle
        @inverted ||= File::JSON.new bundle.index_path(:inverted)
      end
      def create_weights bundle
        @weights ||= File::JSON.new bundle.index_path(:weights)
      end
      def create_similarity bundle
        @similarity ||= File::Marshal.new bundle.index_path(:similarity)
      end
      def create_configuration bundle
        @configuration ||= File::JSON.new bundle.index_path(:configuration)
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
      # Note: In the memory based version we ignore the amount and offset hints.
      #       We cannot use the information to speed up the algorithm, unfortunately.
      #
      def ids combinations, _, _
        return [] if combinations.empty?

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

    end

  end

end