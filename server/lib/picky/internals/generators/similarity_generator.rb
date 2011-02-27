module Internals

  module Generators

    # Uses no similarity as default.
    #
    class SimilarityGenerator < Base

      # Generate a similarity index based on the given index.
      #
      def generate strategy = Similarity::None.new
        strategy.generate_from self.index
      end

    end

  end
  
end