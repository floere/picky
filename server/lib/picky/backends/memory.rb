module Picky

  module Backends

    class Memory < Backend

      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   [:token] # => [id, id, id, id, id] (an array of ids)
      #
      def create_inverted bundle
        JSON.new bundle.index_path(:inverted)
      end
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   [:token] # => 1.23 (a weight)
      #
      def create_weights bundle
        JSON.new bundle.index_path(:weights)
      end
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   [:encoded] # => [:original, :original] (an array of original symbols this similarity encoded thing maps to)
      #
      def create_similarity bundle
        Marshal.new bundle.index_path(:similarity)
      end
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   [:key] # => value (a value for this config key)
      #
      def create_configuration bundle
        JSON.new bundle.index_path(:configuration)
      end
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   [id] # => [:sym1, :sym2]
      #
      def create_realtime bundle
        JSON.new bundle.index_path(:realtime)
      end

    end

  end

end