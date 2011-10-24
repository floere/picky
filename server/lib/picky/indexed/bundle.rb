module Picky

  module Indexed # :nodoc:all

    # An indexed bundle is a number of memory/redis
    # indexes that compose the indexes for a single category:
    #  * core (inverted) index
    #  * weights index
    #  * similarity index
    #  * index configuration
    #
    # Indexed refers to them being indexed.
    # This class notably offers the methods:
    #  * load
    #  * clear
    #
    # To (re)load or clear the current indexes.
    #
    class Bundle < Picky::Bundle

      attr_reader :realtime_mapping

      def initialize name, category, backend, weights_strategy, partial_strategy, similarity_strategy, options = {}
        super name, category, backend, weights_strategy, partial_strategy, similarity_strategy, options

        @inverted      = @backend_inverted.initial
        @weights       = @backend_weights.initial
        @similarity    = @backend_similarity.initial
        @configuration = @backend_configuration.initial

        @realtime_mapping = {} # id -> ary of syms.  TODO Always instantiate?
      end

      # Get the ids for the given symbol.
      #
      # Returns a (potentially empty) array of ids.
      #
      def ids sym
        @inverted[sym] || []
      end

      # Get a weight for the given symbol.
      #
      # Returns a number, or nil.
      #
      def weight sym
        @weights[sym]
      end

      # Get settings for this bundle.
      #
      # Returns an object.
      #
      def [] sym
        @configuration[sym]
      end

      # Loads all indexes.
      #
      # Loading loads index objects from the backend.
      # They should each respond to [] and return something appropriate.
      #
      def load
        load_inverted
        load_weights
        load_similarity
        load_configuration
      end

      # Loads the core index.
      #
      def load_inverted
        self.inverted = @backend_inverted.load
      end
      # Loads the weights index.
      #
      def load_weights
        self.weights = @backend_weights.load
      end
      # Loads the similarity index.
      #
      def load_similarity
        self.similarity = @backend_similarity.load
      end
      # Loads the configuration.
      #
      def load_configuration
        self.configuration = @backend_configuration.load
      end

      # Clears all indexes.
      #
      def clear
        clear_inverted
        clear_weights
        clear_similarity
        clear_configuration
      end

      # Clears the core index.
      #
      def clear_inverted
        inverted.clear
      end
      # Clears the weights index.
      #
      def clear_weights
        weights.clear
      end
      # Clears the similarity index.
      #
      def clear_similarity
        similarity.clear
      end
      # Clears the configuration.
      #
      def clear_configuration
        configuration.clear
      end

    end

  end

end