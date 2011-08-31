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

        private

          # To each shortened token of :test
          # :test, :tes, :te, :t
          # add all ids of :test
          #
          # "token" here means just text.
          #
          # THINK Could be improved by appending the aforegoing ids?
          #
          def generate_for token, inverted, result
            token.each_intoken(min, max) do |intoken|
              if result[intoken]
                result[intoken] += inverted[token] # unique
              else
                result[intoken] = inverted[token].dup
              end
            end
          end

      end

    end

  end

end