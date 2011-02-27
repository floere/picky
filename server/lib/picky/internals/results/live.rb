module Internals

  module Results
    # Live results are not returning any results.
    #
    class Live < Base
    
      self.max_results = 0
    
      def to_log *args
        ?. + super
      end
    
    end
  end
  
end