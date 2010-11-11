module Index
  
  module File
    
    # Index data dumped in the text format.
    #
    class Text < Basic
      
      # Uses the extension "txt".
      #
      def extension
        :txt
      end
      # Text files are used exclusively for
      # prepared data files.
      #
      def load
        raise "Can't load from text file. Use JSON or Marshal."
      end
      # Text files are used exclusively for
      # prepared data files. 
      #
      def dump hash
        raise "Can't dump to text file. Use JSON or Marshal."
      end
      
      # Retrieves prepared index data in the form
      # * id,data\n
      # * id,data\n
      # * id,data\n
      #
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