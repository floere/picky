module Picky
  
  module Loggers
    
    # The verbose logger outputs little information.
    #
    class Concise < Silent
      
      attr_reader :tokenized,
                  :dumped,
                  :loaded
      
      def initialize *args
        super *args
        
        reset
      end
      
      def reset
        @tokenized = false
        @dumped    = false
        @loaded    = false
      end
      
      def info text
        io.write text
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
        io.write type
      end
      
    end
    
  end
  
end
