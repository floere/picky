module Picky

  module Backends

    #
    #
    class Backend
      
      # This is the default behaviour and should be overridden
      # for different backends.
      #
      
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   object[:token] # => [id, id, id, id, id] (an array of ids)
      #
      def create_inverted bundle, _ = nil
        json bundle.index_path(:inverted)
      end
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   object[:key] # => value (a value for this config key)
      #
      def create_configuration bundle, _ = nil
        json bundle.index_path(:configuration)
      end
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   object[id] # => [:sym1, :sym2]
      #
      def create_realtime bundle, _ = nil
        json bundle.index_path(:realtime)
      end

      # # Returns the total score of the combinations.
      # #
      # # Default implementation. Override to speed up.
      # #
      # def score combinations
      #   combinations.score
      # end

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
        # Get the ids for each combination and pass to the optimized C algorithm.
        #
        # Note: It orders the passed arrays by size.
        #
        Performant::Array.memory_efficient_intersect combinations.map { |combination| combination.ids }
      end

      #
      #
      def to_s
        self.class.name
      end

    end

  end

end