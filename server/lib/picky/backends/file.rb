module Picky

  module Backends

    # Naive implementation of a file-based index.
    # In-Memory Hash with length, offset:
    #   { :bla => [20, 312] }
    # That map to positions the File, encoded in JSON?:
    #   ...[1,2,3,21,7,4,13,15]...
    #
    class File < Backend

      def create_inverted bundle
        JSON.new bundle.index_path(:inverted)
      end
      def create_weights bundle
        JSON.new bundle.index_path(:weights)
      end
      def create_similarity bundle
        JSON.new bundle.index_path(:similarity)
      end
      def create_configuration bundle
        JSON.new bundle.index_path(:configuration)
      end

      # Currently, the loaded ids are intersected using
      # the fast C-based intersection.
      #
      # However, if we could come up with a clever way
      # to do this faster, it would be most welcome.
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

    end

  end

end