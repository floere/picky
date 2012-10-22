module Picky
  
  module Loggers
    
    # The verbose logger outputs little information.
    #
    class Concise < Silent
      
      def initialize *args
        super *args
      end
      
      def tokenize(*)
        progress 'T'
      end
      
      def dump(*)
        progress 'D'
      end
      
      def load(*)
        progress
      end
      
      def progress type = '.'
        write type
      end
      
      def adapt_for_logger
        super
        def info text
          output.info text
        end
        def warn text
          output.warn text
        end
        def write message
          output << message
        end
      end
      def adapt_for_io
        super
        def info text
          output.write text
        end
        def warn text
          output.puts text
          flush
        end
        def write message
          output.write message
        end
      end
      
    end
    
  end
  
end
