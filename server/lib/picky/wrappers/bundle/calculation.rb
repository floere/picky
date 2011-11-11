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

        #
        #
        def ids float_as_sym
          @bundle.ids calculate(float_as_sym.to_s.to_f).to_s.to_sym
        end

        #
        #
        def weight float_as_sym
          @bundle.weight calculate(float_as_sym.to_s.to_f).to_s.to_sym
        end

      end

    end

  end

end