module Picky

  module Generators

    module Weights

      # Uses a dynamic weight.
      #
      # Note: This is not saved.
      #
      # Examples:
      #   * Picky::Weights::Dynamic.new do |str_or_sym|
      #       sym_or_str * length
      #     end
      #
      class Dynamic < Stub

        # Give it a block that takes a string/symbol
        # and returns a weight.
        #
        def initialize &calculation
          @calculation = calculation
        end

        # Calls the block to calculate the weight.
        #
        def [] str_or_sym
          @calculation.call str_or_sym
        end

      end

    end

  end

end