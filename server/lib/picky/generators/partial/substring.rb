module Picky
  module Generators
    module Partial
      # Generates the right substrings for use in the substring strategy.
      #
      class SubstringGenerator
        attr_reader :from, :to

        def initialize(from, to)
          super()

          @from = from
          @to = to

          if @to.zero?
            extend ToZero
          elsif @from.negative? && @to.negative?
            extend FromToNegative
          else
            extend Otherwise
          end
        end

        module ToZero
          def each_subtoken(token, &block)
            token.each_subtoken @from, &block
          end
        end

        module FromToNegative
          def each_subtoken(token, &block)
            token.each_subtoken @from - @to - 1, (0..@to), &block
          end
        end

        module Otherwise
          def each_subtoken(token, &block)
            token.each_subtoken @from, (0..@to), &block
          end
        end
      end

      # The subtoken partial strategy.
      #
      # If given "florian"
      # it will index "floria", "flori", "flor", "flo", "fl", "f"
      # (Depending on what the given from value is, the example is with option from: 1)
      #
      class Substring < Strategy
        # The from option signifies where in the symbol it
        # will start in generating the subtokens.
        #
        # Examples:
        #
        # With :hello, and to: -1 (default)
        # * from: 1 # => [:hello, :hell, :hel, :he, :h]
        # * from: 4 # => [:hello, :hell]
        #
        # With :hello, and to: -2
        # * from: 1 # => [:hell, :hel, :he, :h]
        # * from: 4 # => [:hell]
        #
        def initialize(options = {})
          super()

          from = options[:from] || 1
          to   = options[:to]   || -1
          @generator = SubstringGenerator.new from, to
        end

        # Delegator to generator#from.
        #
        def from
          @generator.from
        end

        # Delegator to generator#to.
        #
        def to
          @generator.to
        end

        # Yields each generated partial.
        #
        def each_partial(token, &block)
          @generator.each_subtoken token, &block
        end
      end
    end
  end
end
