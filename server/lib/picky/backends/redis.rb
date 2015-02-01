module Picky

  module Backends

    #
    #
    class Redis < Backend

      attr_reader :client,
                  :realtime

      def initialize options = {}
        maybe_load_hiredis
        check_hiredis_gem
        check_redis_gem

        @client   = options[:client] || ::Redis.new(:db => (options[:db] || 15))
        @realtime = options[:realtime]
      end
      def maybe_load_hiredis
        require 'hiredis'
      rescue LoadError
        # It's ok.
      end
      def check_hiredis_gem
        require 'redis/connection/hiredis'
      rescue LoadError
        # It's ok, the next check will fail if this one does.
      end
      def check_redis_gem
        require 'redis'
      rescue LoadError => e
        warn_gem_missing 'redis', 'the Redis client'
      end

      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:token] # => [id, id, id, id, id] (an array of ids)
      #
      def create_inverted bundle, _ = nil
        List.new client, "#{PICKY_ENVIRONMENT}:#{bundle.identifier}:inverted", realtime: realtime
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:token] # => 1.23 (a weight)
      #
      def create_weights bundle, _ = nil
        Float.new client, "#{PICKY_ENVIRONMENT}:#{bundle.identifier}:weights", realtime: realtime
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:encoded] # => [:original, :original] (an array of original symbols this similarity encoded thing maps to)
      #
      def create_similarity bundle, _ = nil
        List.new client, "#{PICKY_ENVIRONMENT}:#{bundle.identifier}:similarity", realtime: realtime
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:key] # => value (a value for this config key)
      #
      def create_configuration bundle, _ = nil
        String.new client, "#{PICKY_ENVIRONMENT}:#{bundle.identifier}:configuration", realtime: realtime
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [id] # => [:sym1, :sym2]
      #
      def create_realtime bundle, _ = nil
        List.new client, "#{PICKY_ENVIRONMENT}:#{bundle.identifier}:realtime", realtime: realtime
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

      # Returns the total weight for the combinations.
      #
      def weight combinations
        # Note: A nice experiment that generated far too many strings.
        #
        # if redis_with_scripting?
        #   @@weight_script = "local sum = 0; for i=1,#(KEYS),2 do local value = redis.call('hget', KEYS[i], KEYS[i+1]); if value then sum = sum + value end end return sum;"
        #
        #   require 'digest/sha1'
        #   @@weight_sent_once = nil
        #
        #   # Scripting version of #ids.
        #   #
        #   class << self
        #     def weight combinations
        #       namespaces_keys = combinations.inject([]) do |namespaces_keys, combination|
        #         namespaces_keys << "#{combination.bundle.identifier}:weights"
        #         namespaces_keys << combination.token.text
        #       end
        #
        #       # Assume it's using EVALSHA.
        #       #
        #       begin
        #         client.evalsha @@weight_sent_once,
        #                        namespaces_keys.size,
        #                        *namespaces_keys
        #       rescue RuntimeError => e
        #         # Make the server have a SHA-1 for the script.
        #         #
        #         @@weight_sent_once = Digest::SHA1.hexdigest @@weight_script
        #         client.eval @@weight_script,
        #                     namespaces_keys.size,
        #                     *namespaces_keys
        #       end
        #     end
        #   end
        # else
        #   class << self
        #     def weight combinations
            combinations.score
        #     end
        #   end
        # end
        # # Call the newly installed version.
        # #
        # weight combinations
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
        # TODO This is actually not correct:
        #      A dumped/loaded Redis backend should use
        #      the Redis backend calculation method.
        #      So loaded? would be more appropriate.
        #
        if realtime
          # Just checked once on the first call.
          #
          if redis_with_scripting?
            @ids_script = "local intersected = redis.call('zinterstore', ARGV[1], #(KEYS), unpack(KEYS)); if intersected == 0 then redis.call('del', ARGV[1]); return {}; end local results = redis.call('zrange', ARGV[1], tonumber(ARGV[2]), tonumber(ARGV[3])); redis.call('del', ARGV[1]); return results;"

            require 'digest/sha1'
            @ids_script_hash = nil

            # Overrides _this_ method.
            #
            extend Scripting
          else
            # Overrides _this_ method.
            #
            extend NonScripting
          end
        else
          # Remove _this_ method and use the super
          # class method from now on.
          #
          # Note: This fails if there are multiple
          # Redis backends with different versions.
          #
          self.class.send :remove_method, __method__
        end
        # Call the newly installed / super class version.
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
        @intermediate_result_id ||= "#{host}:#{pid}:picky:result"
      end
      
      def identifiers_for combinations
        combinations.inject([]) do |identifiers, combination|
          identifiers << "#{PICKY_ENVIRONMENT}:#{combination.identifier}"
        end
      end
      
      # Uses Lua scripting on Redis 2.6.
      #
      module Scripting
        def ids combinations, amount, offset
          identifiers = identifiers_for combinations

          # Assume it's using EVALSHA.
          #
          begin
            if identifiers.size > 1
              # Reuse script already installed in Redis.
              #
              # Note: This raises an error in Redis,
              # when the script is not installed.
              #
              client.evalsha @ids_script_hash,
                             identifiers,
                             [
                               generate_intermediate_result_id,
                               offset,
                               (offset + amount)
                             ]
            else
              # No complex calculation necessary.
              #
              client.zrange identifiers.first,
                            offset,
                            (offset + amount)
            end
          rescue ::Redis::CommandError => e
            # Install script in Redis.
            #
            @ids_script_hash = client.script 'load', @ids_script
            retry
          end
        end
      end
      
      # Does not use Lua scripting, < Redis 2.6.
      #
      module NonScripting
        def ids combinations, amount, offset
          identifiers = identifiers_for combinations

          result_id = generate_intermediate_result_id

          # Little optimization.
          #
          if identifiers.size > 1
            # Intersect and store.
            #
            intersected = client.zinterstore result_id, identifiers

            # Return clean and early if there has been no intersection.
            #
            if intersected.zero?
              client.del result_id
              return []
            end

            # Get the stored result.
            #
            results = client.zrange result_id, offset, (offset + amount)

            # Delete the stored result as it was only for temporary purposes.
            #
            # Note: I could also not delete it, but that
            #       would not be clean at all.
            #
            client.del result_id
          else
            results = client.zrange identifiers.first, offset, (offset + amount)
          end

          results
        end
      end

    end

  end

end