# encoding: utf-8
#
module Picky

  module Indexed # :nodoc:all

    # TODO Replace inheritance by passing in the backend. Before that, unify the backend interface.
    #
    module Bundle

      # This is the _actual_ index (based on Redis).
      #
      # Handles exact/partial index, weights index, and similarity index.
      #
      class Redis < Base

        def initialize name, category, *args
          super name, category, *args

          @backend = Backend::Redis.new self
        end

      end

    end

  end

end