module Internals
  module Indexed
    module Wrappers

      module Bundle

        # A calculation rewrites the symbol into a float.
        #
        # TODO I really need to allow integers as keys. The code below is just not up to the needed quality.
        #
        class Calculation < Wrapper

          #
          #
          def recalculate float
            float
          end

          #
          #
          def ids sym
            @bundle.ids recalculate(sym.to_s.to_f).to_s.to_sym
          end

          #
          #
          def weight sym
            @bundle.weight recalculate(sym.to_s.to_f).to_s.to_sym
          end

        end

      end

    end
  end
end