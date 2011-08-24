module Picky

  module Backend

    #
    #
    class Redis < Base

      def initialize bundle
        super bundle

        # Refine a few Redis "types".
        #
        @inverted      = Redis::ListHash.new   "#{bundle.identifier}:inverted"
        @weights       = Redis::FloatHash.new  "#{bundle.identifier}:weights"
        @similarity    = Redis::ListHash.new   "#{bundle.identifier}:similarity"
        @configuration = Redis::StringHash.new "#{bundle.identifier}:configuration"
      end

      def to_s
        "#{self.class}(#{[@inverted, @weights, @similarity, @configuration].join(', ')})"
      end

    end

  end

end