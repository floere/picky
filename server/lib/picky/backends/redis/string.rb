module Picky

  module Backends

    class Redis

      class String < Basic

        # Clears the hash.
        #
        def clear
          client.del namespace
        end

        # Returns the size of the hash.
        #
        def size
          client.hlen namespace
        end

        # Deletes the single value.
        #
        def delete key
          client.hdel namespace, key
        end

        # Writes the hash into Redis.
        #
        # Note: We could use multi, but it did not help.
        #
        def dump hash
          unless @realtime
            clear
            hash.each_pair do |key, value|
              client.hset namespace, key, value
            end
          end
        end

        # Get a single value.
        #
        # Internal API method for the index.
        #
        def [] key
          client.hget namespace, key
        end

        # Set a single value
        #
        def []= key, value
          client.hset namespace, key, value
        end

      end

    end

  end

end