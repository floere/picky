module Picky
  
  module Loggers
    
    # The silent logger just gobbles up all information.
    #
    class Silent
      
      attr_reader :io
      
      def initialize io = STDOUT
        @io = io
      end
      
      def info(*)
        
      end
      
      def tokenize(*)
        
      end
      
      def dump(*)
        
      end
      
      def load(*)
        
      end
      
      # Flush this logger.
      #
      def flush
        io.flush
      end
      
    end
    
  end
  
end
