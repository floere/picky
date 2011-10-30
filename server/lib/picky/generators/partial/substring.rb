module Picky

  module Generators

    module Partial

      # Generates the right substrings for use in the substring strategy.
      #
      class SubstringGenerator

        attr_reader :from, :to

        def initialize from, to
          @from, @to = from, to

          if @to.zero?
            def each_subtoken token, &block
              token.each_subtoken @from, &block
            end
          else
            if @from < 0 && @to < 0
              def each_subtoken token, &block
                token[0..@to].intern.each_subtoken @from - @to - 1, &block
              end
            else
              def each_subtoken token, &block
                token[0..@to].intern.each_subtoken @from, &block
              end
            end
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
        def initialize options = {}
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
        def each_partial token, &block
          @generator.each_subtoken token, &block
        end

        # Generates a partial index from the given inverted index.
        #
        def generate_from inverted
          result = {}

          # Generate for each key token the subtokens.
          #
          i = 0
          j = 0
          inverted.each_key do |token|
            i += 1
            if i == 5000
              j += 1
              timed_exclaim %Q{#{"%8i" % (i*j)} generated (current token: "#{token}").}
              i = 0
            end
            generate_for token, inverted, result
          end

          # Remove duplicate ids.
          #
          # THINK If it is unique for a subtoken, it is
          #       unique for all derived longer tokens.
          #
          result.each_value &:uniq!

          result
        end

        # To each shortened token of :test
        # :test, :tes, :te, :t
        # add all ids of :test
        #
        # "token" here means just text.
        #
        # THINK Could be improved by appending the aforegoing ids?
        #
        def generate_for token, inverted, result
          each_partial token do |subtoken|
            if result[subtoken]
              result[subtoken] += inverted[token] # unique
            else
              result[subtoken] = inverted[token].dup
            end
          end
        end

      end

    end

  end

end