module Indexed
  module Wrappers
    
    # Per Bundle wrappers.
    #
    module Bundle
      
      # Base wrapper. Just delegates all methods to the bundle.
      #
      class Wrapper
        
        attr_reader :bundle
        
        def initialize bundle
          @bundle = bundle
        end
        
        delegate :load, :ids, :weight, :identifier, :to => :@bundle
        
      end
      
    end
    
  end
end