module Adapters
  
  #
  #
  module Rack
    
    class LiveInterface < Base

      def initialize live_interface
        @live_interface = live_interface
      end
      
      #
      #
      def to_app options = {}
        # For capturing by the lambda block.
        #
        live_interface = @live_interface
        
        lambda do |env|
          params = ::Rack::Request.new(env).params
          
          results = live_interface.parameters params
          
          respond_with results.to_json
        end
      end
      
    end
    
  end
  
end