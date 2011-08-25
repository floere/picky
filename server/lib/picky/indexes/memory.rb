module Picky

  class Indexes

    # An index that is persisted in files, loaded at startup and kept in memory at runtime.
    #
    class Memory < Index

      def backend_class
        Backends::Memory
      end

    end

  end

end