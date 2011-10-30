module Picky

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

        delegate :[],
                 :[]=,
                 :analyze,
                 :clear,
                 :configuration,
                 :dump,
                 :empty,
                 :load,
                 :generate_caches_from_memory,
                 :generate_caches_from_source,
                 :generate_partial_from,
                 :identifier,
                 :ids,
                 :inverted,
                 :similarity,
                 :size,
                 :weight,
                 :weights,
                 :to => :@bundle

      end

    end

  end

end