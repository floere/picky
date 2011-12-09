module Picky

  module Wrappers

    module Bundle

      # A calculation rewrites the symbol into a float.
      #
      # Note: A calculation will try to find a float in the index,
      #       not a sym.
      #
      # TODO I really need to allow integers as keys.
      #      The code below is just not up to the needed quality.
      #      Use key_format :to_i?
      #
      class Calculation < Wrapper

        # API.
        #
        # By default, a calculation does not
        # calculate anything.
        #
        def calculate float
          float
        end

        # TODO Symbols. Use a block here?
        #
        # THINK Move the calculation elsewhere?
        #
        def ids float_str
          @bundle.ids calculate(float_str.to_f).to_s
        end

        # TODO Symbols.
        #
        # THINK Move the calculation elsewhere?
        #
        def weight float_str
          @bundle.weight calculate(float_str.to_f).to_s
        end

      end

    end

  end

end