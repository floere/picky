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
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [id] # => [:sym1, :sym2]
      #
      def create_realtime bundle
        extract_lambda_or(similarity, bundle) ||
          JSON.new(bundle.index_path(:realtime))
      end

    end

  end

end