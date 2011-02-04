module Index
  
  class Redis
    
    class ListHash < Basic
      
      # Get a collection.
      #
      def collection sym
        @backend.lrange "#{identifier} index #{sym}", 0, 100_000_000_000
      end
      
      # Get a single value.
      #
      def member sym
        raise "Can't retrieve a single value from a Redis ListHash. Use Index::Redis::StringHash."
      end
      
    end
    
  end
  
end