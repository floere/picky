module Picky

  module Backends

    #
    #
    class Redis < Backend

      attr_reader :actual_backend

      def initialize options = {}
        @actual_backend = ::Redis.new :db => (options[:db] || 15)
      end

      def configure_with bundle
        super bundle
        @inverted      = Redis::ListHash.new   "#{bundle.identifier}:inverted",      actual_backend
        @weights       = Redis::FloatHash.new  "#{bundle.identifier}:weights",       actual_backend
        @similarity    = Redis::ListHash.new   "#{bundle.identifier}:similarity",    actual_backend
        @configuration = Redis::StringHash.new "#{bundle.identifier}:configuration", actual_backend
      end

    end

  end

end