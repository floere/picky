module Picky

  module Generators
    module Weights

      # Is used for runtime-only strategies.
      #
      # Note: Pretends to be a backend but
      #       does nothing at all.
      #
      # To override, implement:
      #   * weight_for(size)    # During indextime. # Probably never used.
      #   * [] symbol_or_string # During runtime.
      #
      # TODO Find a better name.
      #
      class Runtime < Strategy

        # It is not saved, by default.
        #
        def saved?
          false
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