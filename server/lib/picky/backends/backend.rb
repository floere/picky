module Picky

  module Backends

    class Backend

      # TODO Move all.
      #

      # Copies the indexes to the "backup" directory.
      #
      def backup
        inverted.backup
        weights.backup
        similarity.backup
        configuration.backup
      end

      # Restores the indexes from the "backup" directory.
      #
      def restore
        inverted.restore
        weights.restore
        similarity.restore
        configuration.restore
      end

      # Delete all index files.
      #
      def delete
        inverted.delete
        weights.delete
        similarity.delete
        configuration.delete
      end

      #
      #
      def to_s
        "#{self.class}(#{[inverted, weights, similarity, configuration].join(', ')})"
      end

    end

  end

end