module Picky

  module Generators

    module Partial

      # Does not generate a partial index.
      #
      class None < Strategy

        # Yields each generated partial.
        #
        def each_partial token
          # yields nothing
        end

        # Returns if this strategy's generated file is saved.
        #
        def saved?
          false
        end

        # Do not use the partial bundle for getting ids and weights.
        #
        def use_exact_for_partial?
          true
        end

      end

    end

  end

end