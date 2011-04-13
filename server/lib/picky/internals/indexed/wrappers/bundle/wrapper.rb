module Internals
  module Indexed
    module Wrappers

      # Per Bundle wrappers.
      #
      module Bundle

        # Base wrapper. Just delegates all methods to the bundle.
        #
        class Wrapper

          attr_reader :bundle

          def initialize bundle
            @bundle = bundle
          end

          delegate :load,
                   :load_index,
                   :load_weights,
                   :load_similarity,
                   :load_configuration,
                   :clear_index,
                   :clear_weights,
                   :clear_similarity,
                   :clear_configuration,
                   :ids,
                   :weight,
                   :identifier,
                   :analyze,
                   :size,
                   :index,
                   :weights,
                   :similarity,
                   :configuration,
                   :to => :@bundle

        end

      end

    end
  end
end