module Internals

  module Generators

    module Similarity

      # Similarity strategy that does nothing.
      #
      class None < Strategy

        # Does not encode text. Just returns nil.
        #
        def encoded text
          nil
        end

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
  
end