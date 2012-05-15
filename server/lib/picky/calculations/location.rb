module Picky

  module Calculations

    # A location calculation recalculates a 1-d location
    # to the Picky internal 1-d "grid".
    #
    # For example, if you have a location x == 12.3456,
    # it will be recalculated into 3, if the minimum is 9
    # and the gridlength is 1.
    #
    class Location

      attr_reader :anchor,
                  :precision,
                  :grid

      def initialize user_grid, anchor = 0.0, precision = nil
        @user_grid  = user_grid
        @precision  = precision || 1
        @grid       = @user_grid / (@precision + 0.5)

        self.anchor = anchor
      end

      def anchor= value
        # Add a margin of 1 user grid.
        #
        value -= @user_grid

        # Add plus 1 grid so that the index key never falls on 0.
        # Why? to_i maps by default to 0.
        #
        value -= @grid

        @anchor = value
      end

      #
      #
      def add_margin length
        @anchor -= length
      end

      #
      #
      def calculated_range location
        range calculate(location)
      end
      #
      #
      def range around_location
        (around_location - @precision)..(around_location + @precision)
      end
      #
      #
      def calculate location
        ((location - @anchor) / @grid).floor
      end

    end

  end

end