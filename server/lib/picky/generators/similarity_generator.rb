module Picky

  module Generators

    # Uses no similarity as default.
    #
    class SimilarityGenerator < Base

      # Generate a similarity index based on the given inverted index.
      #
      def generate strategy = Similarity::None.new
        strategy.generate_from self.inverted
      end

    end

  end

end