module Index
  
  class Redis
    
    class ListHash < Basic
      
      # Writes the hash into Redis.
      #
      def dump hash
        hash.each_pair do |key, value|
          redis_key = "#{namespace}:#{key}"
          @backend.del redis_key # TODO This is wrong, but how to do it? Probably need a prepare_dump.
          @backend.rpush redis_key, value
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