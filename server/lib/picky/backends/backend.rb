module Picky

  module Backends

    #
    #
    class Backend
      
      # This is the default behaviour and should be overridden
      # for different backends.
      #
      # TODO Push down.
      #
      
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   [:token] # => [id, id, id, id, id] (an array of ids)
      #
      def create_inverted bundle
        json bundle.index_path(:inverted)
      end
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   [:token] # => 1.23 (a weight)
      #
      # def create_weights bundle
      #   json bundle.index_path(:weights)
      # end
      # # Returns an object that on #initial, #load returns
      # # an object that responds to:
      # #   [:encoded] # => [:original, :original] (an array of original symbols this similarity encoded thing maps to)
      # #
      # def create_similarity bundle
      #   Marshal.new bundle.index_path(:similarity)
      # end
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   [:key] # => value (a value for this config key)
      #
      def create_configuration bundle
        json bundle.index_path(:configuration)
      end
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   [id] # => [:sym1, :sym2]
      #
      def create_realtime bundle
        json bundle.index_path(:realtime)
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