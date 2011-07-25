module Picky

  module Generators

    module Partial

      # Superclass for partial strategies.
      #
      class Strategy < Generators::Strategy

        # Defines whether to use the exact bundle
        # instead of the partial one.
        #
        # Default is @false@.
        #
        # For example:
        #  Partial::None.new # Uses the exact index instead of the partial one.
        #
        def use_exact_for_partial?
          false
        end

      end

    end

  end

end