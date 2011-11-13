module Picky

  module Generators

    module Partial

      # The subtoken partial strategy.
      #
      # If given "florian"
      # it will index "floria", "flori", "flor", "flo", "fl", "f"
      # (Depending on what the given from value is, the example is with option from: 1)
      #
      class Infix < Strategy

        attr_reader :min,
                    :max

        # The min option signifies with what size it
        # will start in generating the infix tokens.
        #
        # Examples:
        #
        # With :hello, and max: -1 (default)
        # * min: 1 # => [:hello, :hell, :ello, :hel, :ell, :llo, :he, :el, :ll, :lo, :h, :e, :l, :l, :o]
        # * min: 4 # => [:hello, :hell, :ello]
        #
        # With :hello, and max: -2
        # * min: 1 # => [:hell, :ello, :hel, :ell, :llo, :he, :el, :ll, :lo, :h, :e, :l, :l, :o]
        # * min: 4 # => [:hell, :ello]
        #
        # (min 1 is default)
        #
        def initialize options = {}
          @min = options[:min] || 1
          @max = options[:max] || -1
        end

        # Yields each generated partial.
        #
        def each_partial token, &block
          token.each_intoken min, max, &block
        end

      end

    end

  end

end