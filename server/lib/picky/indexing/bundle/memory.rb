module Picky

  # encoding: utf-8
  #
  module Indexing # :nodoc:all

    module Bundle

      # The memory version dumps its generated indexes to disk
      # (mostly JSON) to load them into memory on startup.
      #
      # TODO Replace inheritance by passing in the backend.
      #
      class Memory < Base

        def initialize name, category, *args
          super name, category, *args

          @backend = Backend::Files.new self
        end

      end

    end

  end

end