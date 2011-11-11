# encoding: utf-8
#
module Picky

  module Wrappers

    module Bundle

      # This index combines a partial and exact
      # bundle such that a partial index will not
      # be dumped or generated.
      #
      class ExactPartial

        attr_reader :bundle

        include Delegator
        include IndexedDelegator

        def initialize bundle
          @bundle = bundle
        end

        def clear; end
        def dump; end
        def empty; end
        def generate_caches_from_memory; end
        def generate_partial_from arg; end
        def index; end
        def load; end

      end

    end

  end

end