module Picky

  module Backends

    #
    #
    class Redis < Backend

      attr_reader :client

      def initialize options = {}
        super options

        require 'redis'
        @client = options[:client] || ::Redis.new(:db => (options[:db] || 15))
      rescue LoadError => e
        warn_gem_missing 'redis', 'the Redis client'
      end

      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:token] # => [id, id, id, id, id] (an array of ids)
      #
      def create_inverted bundle
        extract_lambda_or(inverted, bundle, client) ||
          List.new(client, "#{bundle.identifier}:inverted")
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:token] # => 1.23 (a weight)
      #
      def create_weights bundle
        extract_lambda_or(weights, bundle, client) ||
          Float.new(client, "#{bundle.identifier}:weights")
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:encoded] # => [:original, :original] (an array of original symbols this similarity encoded thing maps to)
      #
      def create_similarity bundle
        extract_lambda_or(similarity, bundle, client) ||
          List.new(client, "#{bundle.identifier}:similarity")
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:key] # => value (a value for this config key)
      #
      def create_configuration bundle
        extract_lambda_or(configuration, bundle, client) ||
          String.new(client, "#{bundle.identifier}:configuration")
      end

      # Does the Redis version already include
      # scripting support?
      #
      def redis_with_scripting?
        at_least_version redis_version, [2, 6, 0]
      end

      # Compares two versions each in an array [major, minor, patch]
      # format and returns true if the first version is higher
      # or the same as the second one. False if not.
      #
      # Note: Destructive.
      #
      def at_least_version major_minor_patch, should_be
        3.times { return false if major_minor_patch.shift < should_be.shift }
        true
      end

      # Returns an array describing the
      # current Redis version.
      #
      # Note: This method assumes that clients answer
      #       to #info with a hash (string/symbol keys)
      #       detailing the infos.
      #
      # Example:
      #   backend.redis_version # => [2, 4, 1]
      #
      def redis_version
        infos          = client.info
        version_string = infos['redis_version'] || infos[:redis_version]
        version_string.split('.').map &:to_i
      end

      # Returns the result ids for the allocation.
      #
      # Developers wanting to program fast intersection
      # routines, can do so analogue to this in their own
      # backend implementations.
      #
      # Note: We use the amount and offset hints to speed Redis up.
      #
      def ids combinations, amount, offset
        if redis_with_scripting?
          @@script = <<-SCRIPT
redis.call('zinterstore', KEYS[1], ARGV);
local results = redis.call('zrange', KEYS[1], tonumber(KEYS[2]), tonumber(KEYS[3]));
redis.call('del', KEYS[1]);
return results;
SCRIPT
          # Scripting version of #ids.
          #
          def ids combinations, amount, offset
            identifiers = combinations.inject([]) do |identifiers, combination|
              identifiers << "#{combination.identifier}"
            end

            # Assume it's using EVALSHA.
            #
            # TODO It's not.
            #
            client.eval @@script, 3, generate_intermediate_result_id, offset, (offset + amount), *identifiers
          end
        else
          # Non-Scripting version of #ids.
          #
          def ids combinations, amount, offset
            identifiers = combinations.inject([]) do |identifiers, combination|
              identifiers << "#{combination.identifier}"
            end

            result_id = generate_intermediate_result_id

            # Intersect and store.
            #
            client.zinterstore result_id, identifiers

            # Get the stored result.
            #
            results = client.zrange result_id, offset, (offset + amount)

            # Delete the stored result as it was only for temporary purposes.
            #
            # Note: I could also not delete it, but that would not be clean at all.
            #
            client.del result_id

            results
          end
        end

        # Call the newly installed version.
        #
        ids combinations, amount, offset
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