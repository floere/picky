module Index
  
  module File
    
    class Marshal < Basic
      
      def extension
        :dump
      end
      def load
        ::Marshal.load ::File.open(cache_path, 'r:binary')
      end
      def dump hash
        hash.dump_to_marshalled cache_path
      end
      def retrieve
        raise "Can't retrieve from marshalled file. Use text file."
      end
      
    end
    
  end
  
end