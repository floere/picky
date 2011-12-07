module Picky

  module Generators
    module Weights

      # Is used for runtime-only strategies.
      #
      # Note: Pretends to be a backend but
      #       does nothing at all.
      #
      # To override, implement:
      #   * [symbol_or_string] # During runtime.
      #   * weight_for(size)   # During indextime. # Probably never used.
      #
      class Stub < Strategy

        # It is not saved, by default.
        #
        def saved?
          false
        end

        # Nothing needs to be deleted from it.
        #
        def delete _

        end

        # It does not need to be cleared.
        #
        def clear

        end

        # Returns nil.
        #
        def weight_for _
          # Nothing.
        end

        # Saves nothing by default.
        #
        def []= _, _

        end

      end
    end
  end

end