module Picky

  class Indexes

    # An index that is persisted in Redis.
    #
    class Redis < Index

      def backend_class
        Backends::Redis
      end

    end

  end

end