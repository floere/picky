module Query

  # Combinations are a number of Combination-s.
  #
  # They are the core of an allocation.
  # An allocation consists of a number of combinations.
  #
  module Combinations # :nodoc:all

    # Redis Combinations contain specific methods for
    # calculating score and ids in memory.
    #
    class Redis < Base

      # Connect to the backend.
      #
      # TODO Use specific Picky Redis wrapper.
      #
      def self.redis
        @redis ||= ::Redis.new :db => 15
      end

      attr_reader :redis

      #
      #
      def initialize combinations
        super combinations

        @redis = self.class.redis
      end

      # Returns the result ids for the allocation.
      #
      def ids amount, offset
        return [] if @combinations.empty?

        identifiers = @combinations.inject([]) do |identifiers, combination|
          identifiers << "#{combination.identifier}"
        end

        result_id = generate_intermediate_result_id

        # Intersect and store.
        #
        redis.zinterstore result_id, identifiers

        # Get the stored result.
        #
        results = redis.zrange result_id, offset, (offset + amount)

        # Delete the stored result as it was only for temporary purposes.
        #
        # Note: I could also not delete it, but that would not be clean at all.
        #
        redis.del result_id

        results
      end

      # Generate a multiple host/process safe result id.
      #
      # Note: Generated when this class loads.
      #
      require 'socket'
      def self.extract_host
        @host ||= Socket.gethostname
      end
      def host
        self.class.extract_host
      end
      extract_host
      def pid
        @pid ||= Process.pid
      end
      # Use the host and pid (generated lazily in child processes) for the result.
      #
      def generate_intermediate_result_id
        :"#{host}:#{pid}:picky:result"
      end

    end

  end

end