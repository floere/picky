module Picky
  
  module Loggers
    
    # The silent logger just gobbles up all information.
    #
    class Silent
      
      attr_reader :output
      
      def initialize output = STDOUT
        @output = output
        adapt
      end
      
      # Is the output a logger?
      #
      def logger_output?
        output.respond_to?(:fatal) &&
        output.respond_to?(:error) &&
        output.respond_to?(:warn)  &&
        output.respond_to?(:info)  &&
        output.respond_to?(:debug)
      end
      
      def adapt
        logger_output? ? adapt_for_logger : adapt_for_io
      end
      
      def adapt_for_logger
        def flush
            
        end
      end
      def adapt_for_io
        def flush
          output.flush
        end
      end
      
      def info(*)
        
      end
      
      def warn(*)
        
      end
      
      def write(*)
        
      end
      
      def tokenize(*)
        
      end
      
      def dump(*)
        
      end
      
      def load(*)
        
      end
      
    end
    
  end
  
end
