module Picky

  module Adapters
    # Adapter that is plugged into a Rack outlet.
    #
    module Rack

      # Subclasses of this class should respond to
      # * to_app(options)
      #
      class Base

        # Puts together an appropriately structured Rack response.
        #
        # Note: Bytesize is needed to have special characters not trip up Rack.
        #
        def respond_with response, content_type = 'application/json'
          [200, { 'Content-Type' => content_type, 'Content-Length' => response.bytesize.to_s }, [response]]
        end

      end

    end

  end

end