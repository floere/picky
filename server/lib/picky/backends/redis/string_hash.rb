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
            backend.hset namespace, key, value
          end
        end

        # Clears the hash.
        #
        def clear
          backend.del namespace
        end

        # Get a single value.
        #
        # Internal API method for the index.
        #
        def [] key
          backend.hget namespace, key
        end

      end

    end

  end

end