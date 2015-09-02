module Picky

  module Backends

    class Redis

      class List < Basic

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

        # Size of the list(s).
        #
        def size
          redis_key = "#{namespace}:*"
          client.keys(redis_key).inject(0) do |total, key|
            total + client.zcard(key)
          end
        end

        # Deletes the list for the key.
        #
        def delete key
          client.del "#{namespace}:#{key}"
        end

        # Writes the hash into Redis.
        #
        def dump hash
          unless @realtime
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
        end

        # Get a collection.
        #
        # Internal API method for the index.
        #
        def [] key
          list = client.zrange "#{namespace}:#{key}", :'0', :'-1'
          
          DirectlyManipulable.make self, list, key
          
          list
        end

        # Set a single list.
        #
        def []= key, values
          delete key

          redis_key = "#{namespace}:#{key}"
          i = 0
          values.each do |value|
            i += 1
            client.zadd redis_key, i, value
          end
          
          DirectlyManipulable.make self, values, key
          
          values
        end
        
        # Inject.
        #
        def inject initial, &block
          redis_keys = "#{namespace}:*"
          client.keys(redis_keys).each do |redis_key|
            key = redis_key[/:([^\:]+)$/, 1]
            initial = block.call initial, [key, self[key]]
          end
          initial
        end

      end

    end

  end

end