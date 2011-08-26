module Picky

  module Backends

    class Redis

      class StringHash < Basic

        # Writes the hash into Redis.
        #
        # Note: We could use multi, but it did not help.
        #
        def dump hash
          clear
          hash.each_pair do |key, value|
            client.hset namespace, key, value
          end
        end

        # Clears the hash.
        #
        def clear
          client.del namespace
        end

        # Get a single value.
        #
        # Internal API method for the index.
        #
        def [] key
          client.hget namespace, key
        end

      end

    end

  end

end