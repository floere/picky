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
      
      def adapt_for_logger
        super
        def info text
          output.info text
        end
        def progress type = '.'
          write type
        end
      end
      def adapt_for_io
        super
        def info text
          output.puts text
        end
        def progress type = '.'
          write type
        end
      end
      
    end
    
  end
  
end
