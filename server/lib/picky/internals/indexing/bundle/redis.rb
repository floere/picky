# encoding: utf-8
#
module Internals

  module Indexing # :nodoc:all

    module Bundle

      # The Redis version dumps its generated indexes to
      # the Redis backend.
      #
      class Redis < Base

        attr_reader :backend

        def initialize name, category, *args
          super name, category, *args

          @backend = Internals::Index::Redis.new name, category
        end

      end

    end

  end

end