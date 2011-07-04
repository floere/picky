module Internals

  module Generators
  
    class Strategy
    
      # By default, all caches are saved in a
      # storage (like a file).
      #
      def saved?
        true
      end
    
    end
  
  end
  
end