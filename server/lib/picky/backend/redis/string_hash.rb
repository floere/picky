module Picky

  module Backend

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

        # Get a collection.
        #
        def collection key
          raise "Can't retrieve collection for :#{key} from a StringHash. Use Indexes::Redis::ListHash."
        end

        # Get a single value.
        #
        def member key
          backend.hget namespace, key
        end

      end

    end

  end

end