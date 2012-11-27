module Picky

  module Wrappers

    # Per Bundle wrappers.
    #
    module Bundle

      # Base wrapper. Just forwards all methods to the bundle.
      #
      class Wrapper

        include Delegator
        include IndexingDelegator
        include IndexedDelegator

        attr_reader :bundle

        def initialize bundle
          @bundle = bundle
        end

      end

    end

  end

end