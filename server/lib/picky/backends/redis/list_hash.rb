module Picky

  module Backends

    class Redis

      class ListHash < Basic

        # Writes the hash into Redis.
        #
        def dump hash
          clear
          hash.each_pair do |key, values|
            redis_key = "#{namespace}:#{key}"
            i = 0
            values.each do |value|
              i += 1
              client.zadd redis_key, i, value
            end
          end
        end

        # Clear the index for this list.
        #
        # Note: Perhaps we can use a server only command.
        #       This is not the optimal way to do it.
        #
        def clear
          redis_key = "#{namespace}:*"
          client.keys(redis_key).each do |key|
            client.del key
          end
        end

        # Get a collection.
        #
        # Internal API method for the index.
        #
        def [] key
          client.zrange "#{namespace}:#{key}", 0, -1
        end

      end

    end

  end

end