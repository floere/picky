module Picky

  module Generators # :nodoc:all

    # A cache generator holds an index.
    #
    class Base

      attr_reader :inverted

      def initialize inverted
        @inverted = inverted
      end

    end

  end

end