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
        @weights       = Redis::StringHash.new "#{bundle.identifier}:weights"
        @similarity    = Redis::ListHash.new   "#{bundle.identifier}:similarity"
        @configuration = Redis::StringHash.new "#{bundle.identifier}:configuration"
      end

      # Delegate to the right collection.
      #
      def ids sym
        inverted.collection sym
      end

      # Delegate to the right member value.
      #
      # Note: Converts to float.
      #
      def weight sym
        weights.member(sym).to_f
      end

      # Delegate to a member value.
      #
      def setting sym
        configuration.member sym
      end

    end

  end

end