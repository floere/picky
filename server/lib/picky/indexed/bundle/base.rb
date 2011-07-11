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
  module Bundle

    class Base < ::Bundle

      # Loads all indexes.
      #
      def load
        load_inverted
        load_weights
        load_similarity
        load_configuration
      end

      # Clears all indexes.
      #
      def clear
        clear_inverted
        clear_weights
        clear_similarity
        clear_configuration
      end

    end

  end

end