module Index
  
  class Redis
    
    class StringHash < Basic
      
      # Get a collection.
      #
      def collection sym
        raise "Can't retrieve a collection from a StringHash. Use Index::Redis::ListHash."
      end
      
      # Get a single value.
      #
      def member sym
        @backend.get "#{identifier} weight #{sym}"
      end
      
    end
    
  end
  
end