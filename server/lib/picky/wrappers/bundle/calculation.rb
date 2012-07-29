module Picky

  module Wrappers

    module Bundle

      # A calculation rewrites the symbol into a float.
      #
      # Note: A calculation will try to find a float in the index,
      #       not a sym.
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

        # SYMBOLS. Use a block here?
        #
        # THINK Move the calculation elsewhere?
        #
        def ids float_str
          @bundle.ids calculate(float_str.to_f).to_s
        end

        # SYMBOLS.
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