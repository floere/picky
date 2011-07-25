module Picky

  # encoding: utf-8
  #
  module Indexing # :nodoc:all

    module Bundle

      # The Redis version dumps its generated indexes to
      # the Redis backend.
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