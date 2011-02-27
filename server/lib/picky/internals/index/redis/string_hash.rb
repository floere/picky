module Internals

  module Index
  
    class Redis
    
      class StringHash < Basic
      
        # Writes the hash into Redis.
        #
        def dump hash
          hash.each_pair do |key, value|
            @backend.hset namespace, key, value
          end
        end
      
        # Get a collection.
        #
        def collection sym
          raise "Can't retrieve a collection from a StringHash. Use Index::Redis::ListHash."
        end
      
        # Get a single value.
        #
        def member sym
          @backend.hget namespace, sym
        end
      
      end
    
    end
  
  end
  
end