module Internals

  module Index

    # TODO Needs a reconnect to be run after forking.
    #
    class Redis < Backend

      def initialize bundle_name, category
        super bundle_name, category

        # Refine a few Redis "types".
        #
        @index         = Redis::ListHash.new "#{category.identifier}:#{bundle_name}:index"
        @weights       = Redis::StringHash.new "#{category.identifier}:#{bundle_name}:weights"
        @similarity    = Redis::ListHash.new "#{category.identifier}:#{bundle_name}:similarity"
        @configuration = Redis::StringHash.new "#{category.identifier}:#{bundle_name}:configuration"
      end

      # Delegate to the right collection.
      #
      def ids sym
        index.collection sym
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