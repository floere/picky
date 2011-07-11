# encoding: utf-8
#
module Indexed # :nodoc:all

  #
  #
  module Bundle

    # This is the _actual_ index (based on Redis).
    #
    # Handles exact/partial index, weights index, and similarity index.
    #
    class Redis < Base

      def initialize name, category, *args
        super name, category, *args

        @backend = Backend::Redis.new self
      end

      # Get the ids for the given symbol.
      #
      # Ids are an array of string values in Redis.
      #
      def ids sym
        @backend.ids sym
      end
      # Get a weight for the given symbol.
      #
      # A weight is a string value in Redis. TODO Convert?
      #
      def weight sym
        @backend.weight sym
      end
      # Settings of this bundle can be accessed via [].
      #
      def [] sym
        @backend.setting sym
      end

      # Loads the inverted index.
      #
      def load_inverted
        # No loading needed.
      end
      # Loads the weights index.
      #
      def load_weights
        # No loading needed.
      end
      # Loads the similarity index.
      #
      def load_similarity
        # No loading needed.
      end
      # Loads the configuration.
      #
      def load_configuration
        # No loading needed.
      end

      # Loads the inverted index.
      #
      def clear_inverted
        # No clearing possible, currently.
      end
      # Loads the weights index.
      #
      def clear_weights
        # No clearing possible, currently.
      end
      # Loads the similarity index.
      #
      def clear_similarity
        # No clearing possible, currently.
      end
      # Loads the configuration.
      #
      def clear_configuration
        # No clearing possible, currently.
      end

    end

  end

end