module Picky

  module Generators

    module Weights

      # Uses a constant weight.
      # Default is 0.0.
      #
      # Note: This is not saved.
      #
      # Examples:
      #   * Picky::Weights::Constant.new       # Uses 0.0 as a constant weight.
      #   * Picky::Weights::Constant.new(3.14) # Uses 3.14 as a constant weight.
      #
      class Constant < Stub

        def initialize weight = 0.0
          @weight = weight
        end

        # Always returns the constant weight,
        # except if there are no ids.
        #
        def [] _
          @weight
        end

        # Returns the constant weight,
        # except if there are no ids.
        #
        # Not really used, but is more
        # correct this way.
        #
        def weight_for _
          @weight
        end

      end

    end

  end

end