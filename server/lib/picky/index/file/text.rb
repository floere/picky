module Index
  
  module File
    
    class Text < Basic
      
      def extension
        :txt
      end
      def load
        raise "Can't load from text file. Use JSON or Marshal."
      end
      def dump hash
        raise "Can't dump to text file. Use JSON or Marshal."
      end
      def retrieve
        ::File.open(cache_path, 'r:binary') do |file|
          file.each_line do |line|
            yield line.split ?,, 2
          end
        end
      end
      
    end
    
  end
  
end