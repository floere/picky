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
      
      # Yields an id and a symbol token.
      #
      def retrieve
        id, token =
        ::File.open(cache_path, 'r:binary') do |file|
          file.each_line do |line|
            id, token = line.split ?,, 2
            yield id.to_i, (token.chomp! || token).to_sym
          end
        end
      end
      
    end
    
  end
  
end