module Index
  
  module File
    
    class JSON < Basic
      
      def extension
        :json
      end
      def load
        Yajl::Parser.parse ::File.open(cache_path, 'r'), :symbolize_keys => true
      end
      def dump hash
        hash.dump_to_json cache_path
      end
      def retrieve
        raise "Can't retrieve from marshalled file. Use text file."
      end
      
    end
    
  end
  
end