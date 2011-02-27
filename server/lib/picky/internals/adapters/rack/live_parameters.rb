module Adapters
  
  #
  #
  module Rack
    
    class LiveParameters < Base

      def initialize live_parameters
        @live_parameters = live_parameters
      end
      
      #
      #
      def to_app options = {}
        # For capturing by the lambda block.
        #
        live_parameters = @live_parameters
        
        lambda do |env|
          params = ::Rack::Request.new(env).params
          
          results = live_parameters.parameters params
          
          respond_with results.to_json
        end
      end
      
    end
    
  end
  
end