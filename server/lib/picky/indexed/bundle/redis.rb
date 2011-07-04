module Internals

  # encoding: utf-8
  #
  module Indexed # :nodoc:all

    #
    #
    module Bundle

      # This is the _actual_ index (based on Redis).
      #
      # Handles exact/partial index, weights index, and similarity index.
      #
      class Redis < Base

        def initialize name, category, *args
          super name, category, *args

          @backend = Internals::Index::Redis.new name, category
        end

        # Get the ids for the given symbol.
        #
        # Ids are an array of string values in Redis.
        #
        def ids sym
          @backend.ids sym
        end
        # Get a weight for the given symbol.
        #
        # A weight is a string value in Redis. TODO Convert?
        #
        def weight sym
          @backend.weight sym
        end
        # Settings of this bundle can be accessed via [].
        #
        def [] sym
          @backend.setting sym
        end

      end

    end

  end

end