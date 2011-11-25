module Picky

  module Backends

    class Redis

      class List < Basic

        # Writes the hash into Redis.
        #
        def dump hash
          unless @immediate
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
          list = client.zrange "#{namespace}:#{key}", 0, -1
          realtime_extend list, key
          list
        end

        # Set a single list.
        #
        def []= key, values
          redis_key = "#{namespace}:#{key}"
          i = 0
          values.each do |value|
            i += 1
            client.zadd redis_key, i, value
          end
        end

        def realtime_extend array, key
          array.extend Realtime
          array.db = self
          array.key = key
        end

        module Realtime
          attr_accessor :db, :key
          def << value
            super value
            db[key] = self
          end

          def unshift value
            super value
            db[key] = self
          end
        end

        # Deletes the list.
        #
        def delete key
          p [:DELETE_LIST]
        end

      end

    end

  end

end