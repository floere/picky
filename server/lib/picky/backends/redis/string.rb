module Picky

  module Backends

    class Redis

      class String < Basic

        # Writes the hash into Redis.
        #
        # Note: We could use multi, but it did not help.
        #
        def dump hash
          unless @immediate
            clear
            hash.each_pair do |key, value|
              client.hset namespace, key, value
            end
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

        # Set a single value
        #
        def []= key, value
          client.hset namespace, key, value
        end

        # Deletes the single value.
        #
        def delete key
          p [:DELETE_VALUE]
        end

      end

    end

  end

end