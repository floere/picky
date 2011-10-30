module Picky

  module Generators

    module Partial

      class Postfix < Substring

        # The from option signifies where in the symbol it
        # will start in generating the subtokens.
        #
        # Examples:
        #
        # With :hello
        # * from: 1 # => [:hello, :hell, :hel, :he, :h]
        # * from: 4 # => [:hello, :hell]
        #
        def initialize options = {}
          options[:to] = -1

          super options
        end

      end

    end

  end

end