module Picky

  module Backends

    # Naive implementation of a file-based index.
    # In-Memory Hash with length, offset:
    #   { :bla => [20, 312] }
    # That map to positions the File, encoded in JSON:
    #   ...[1,2,3,21,7,4,13,15]...
    #
    class File < Backend

      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:token] # => [id, id, id, id, id] (an array of ids)
      #
      def create_inverted bundle
        extract_lambda_or(inverted, bundle) ||
          JSON.new(bundle.index_path(:inverted))
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:token] # => 1.23 (a weight)
      #
      def create_weights bundle
        extract_lambda_or(weights, bundle) ||
          JSON.new(bundle.index_path(:weights))
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:encoded] # => [:original, :original] (an array of original symbols this similarity encoded thing maps to)
      #
      def create_similarity bundle
        extract_lambda_or(similarity, bundle) ||
          JSON.new(bundle.index_path(:similarity))
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:key] # => value (a value for this config key)
      #
      def create_configuration bundle
        extract_lambda_or(configuration, bundle) ||
          JSON.new(bundle.index_path(:configuration))
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