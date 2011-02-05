module Index
  
  class Redis
    
    # Redis Backend Accessor.
    #
    # Provides necessary helper methods for its
    # subclasses.
    # Not directly useable, as it does not provide
    # dump/load methods.
    #
    class Basic
      
      attr_reader :namespace
      
      # An index cache takes a path, without file extension,
      # which will be provided by the subclasses.
      #
      def initialize namespace
        @namespace = namespace
        
        @backend   = ::Redis.new
      end
      
      # Does nothing.
      #
      def load
        # Nothing.
      end
      # We do not use Redis to retrieve data.
      #
      def retrieve
        # Nothing.
      end
      
      # Redis does not backup.
      #
      def backup
        # Nothing.
      end
      
      # Deletes the Redis index namespace.
      #
      def delete
        # TODO @backend.
      end
      
      # Checks.
      #
      
      # Is this cache suspiciously small?
      #
      def cache_small?
        false # TODO
      end
      # Is the cache ok?
      #
      # A small cache is still ok.
      #
      def cache_ok?
        false # TODO
      end
      # Extracts the size of the file in Bytes.
      #
      def size_of path
        # TODO
      end
      
    end
    
  end
  
end