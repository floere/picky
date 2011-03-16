module Internals

  module Adapters
    # This is an adapter that is plugged into a Rack outlet.
    #
    # It looks at what is given to it and generate an appropriate
    # adapter for it.
    #
    # For example, if you give it a query, it will extract the query param etc.
    # and call search_with_text on it if it is called by Rack.
    #
    module Rack

      class Query < Base

        @@defaults = {
          query_key:    'query'.freeze,
          ids_key:      'ids'.freeze,
          offset_key:   'offset'.freeze,
          content_type: 'application/json'.freeze
        }

        def initialize query
          @query    = query
          @defaults = @@defaults.dup
        end

        def to_app options = {}
          # For capturing in the lambda.
          #
          query        = @query
          query_key    = options[:query_key]    || @defaults[:query_key]
          content_type = options[:content_type] || @defaults[:content_type]

          lambda do |env|
            params  = ::Rack::Request.new(env).params

            results = query.search_with_text *extracted(params)

            PickyLog.log results.to_log(params[query_key])

            respond_with results.to_response, content_type
          end
        end

        # Helper method to extract the params
        #
        # Defaults are 20 ids, offset 0.
        #
        UTF8_STRING = 'UTF-8'.freeze
        def extracted params
          [
            # query is encoded in ASCII
            #
            params[@defaults[:query_key]]  && params[@defaults[:query_key]].force_encoding(UTF8_STRING),
            params[@defaults[:ids_key]]    && params[@defaults[:ids_key]].to_i || 20,
            params[@defaults[:offset_key]] && params[@defaults[:offset_key]].to_i || 0
          ]
        end

      end

    end

  end

end