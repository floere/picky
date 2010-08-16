module Cacher

  module Partial

    # Does not generate a partial index.
    #
    class None < Strategy

      # Returns an empty index.
      #
      def generate_from index
        {}
      end

    end

  end

end