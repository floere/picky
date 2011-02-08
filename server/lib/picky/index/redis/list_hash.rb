module Index
  
  class Redis
    
    class ListHash < Basic
      
      # Writes the hash into Redis.
      #
      # TODO Performance: rpush as you get the values instead of putting it together in an array first.
      #
      def dump hash
        hash.each_pair do |key, values|
          redis_key = "#{namespace}:#{key}"
          @backend.multi do
            @backend.del redis_key
            
            values.each do |value|
              @backend.rpush redis_key, value
            end
          end
        end
      end
      
      # Get a collection.
      #
      def collection sym
        @backend.lrange "#{namespace}:#{sym}", 0, -1
      end
      
      # Get a single value.
      #
      def member sym
        raise "Can't retrieve a single value from a Redis ListHash. Use Index::Redis::StringHash."
      end
      
    end
    
  end
  
end