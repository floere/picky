# encoding: utf-8
#
module Picky

  module Wrappers

    module Bundle

      # This index combines a partial and exact
      # bundle such that a partial index will not
      # be dumped or generated.
      #
      class ExactPartial < Wrapper

        # Ignore these.
        #
        def clear; end
        def dump; end
        def empty; end
        def index; end
        def load(*); end
        
        def to_tree_s indent = 0
          bundle.to_tree_s(indent) { "(reference)" }
        end

      end

    end

  end

end