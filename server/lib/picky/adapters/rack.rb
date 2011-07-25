module Picky

  module Adapters

    # This is an adapter that is plugged into a Rack outlet.
    #
    # It looks at what is given to it and generate an appropriate
    # adapter for it.
    #
    # For example, if you give it a query, it will extract the query param etc.
    # and call search_with_text on it if it is called by Rack.
    #
    # Usage:
    #   Adapters::Rack.app_for(thing, options)
    #
    module Rack

      # Generates the appropriate app for Rack.
      #
      @@mapping = {
        :search_with_text => Search,
        :parameters       => LiveParameters
      }
      def self.app_for thing, options = {}
        @@mapping.each_pair do |method, adapter|
          return adapter.new(thing).to_app(options) if thing.respond_to?(method)
        end
      end

    end

  end

end