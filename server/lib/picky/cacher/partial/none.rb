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
      
      # Returns if this strategy's generated file is saved.
      #
      def saved?
        false
      end

    end

  end

end