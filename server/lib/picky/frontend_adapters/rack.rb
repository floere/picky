require 'rack/mount'

module Internals

  module FrontendAdapters

    # TODO Rename to Routing again. Push everything back into appropriate Adapters.
    #
    class Rack # :nodoc:all

      #
      #
      def reset_routes
        @routes = ::Rack::Mount::RouteSet.new
      end
      def routes
        @routes || reset_routes
      end
      def finalize
        routes.freeze
      end

      # Routing simply delegates to the route set to handle a request.
      #
      def call env
        routes.call env
      end

      # API method.
      #
      def route options = {}
        mappings, route_options = split options
        mappings.each do |url, query|
          route_one url, query, route_options
        end
      end
      # Splits the route method options
      # into real options and route options (/regexp/ => thing or 'some/path' => thing).
      #
      def split options
        mappings      = {}
        route_options = {}
        options.each_pair do |key, value|
          if Regexp === key or String === key
            mappings[key] = value
          else
            route_options[key] = value
          end
        end
        [mappings, route_options]
      end
      def route_one url, query, route_options = {}
        raise RouteTargetNilError.new(url) unless query
        routes.add_route Internals::Adapters::Rack.app_for(query, route_options), default_options(url, route_options), {}, query.to_s
      end
      class RouteTargetNilError < StandardError
        def initialize url
          @url = url
        end
        def to_s
          "Routing for #{@url.inspect} was defined with a nil target object, i.e. #{@url.inspect} => nil."
        end
      end
      #
      #
      def root status
        answer %r{^/$}, STATUSES[status]
      end
      #
      #
      def default status
        answer nil, STATUSES[status]
      end



      # TODO Can Rack handle this for me?
      #
      # Note: Rack-mount already handles the 404.
      #
      STATUSES = {
        200 => lambda { |_| [200, { 'Content-Type' => 'text/html', 'Content-Length' => '0' }, ['']] },
        404 => lambda { |_| [404, { 'Content-Type' => 'text/html', 'Content-Length' => '0' }, ['']] }
      }

      #
      #
      def default_options url, route_options = {}
        url = normalized url

        options = { request_method: 'GET' }.merge route_options

        options[:path_info] = url if url

        options.delete :content_type

        query_params = options.delete :query
        options[:query_string] = %r{#{generate_query_string(query_params)}} if query_params

        options
      end
      #
      #
      def generate_query_string query_params
        raise "At least one query string condition is needed." if query_params.size.zero?
        raise "Too many query param conditions (only 1 allowed): #{query_params}" if query_params.size > 1
        k, v = query_params.first
        "#{k}=#{v}"
      end

      # Setup a route that answers using the given app.
      #
      def answer url = nil, app = nil
        routes.add_route (app || STATUSES[200]), default_options(url)
      end

      # Returns a regular expression for the url if it is given a String-like object.
      #
      def normalized url
        url.respond_to?(:to_str) ? %r{#{url}} : url
      end

      # Returns true if there are no routes defined.
      #
      def empty?
        routes.length.zero?
      end

      # TODO Beautify. Rewrite!
      #
      def to_s
        max_length = routes.instance_variable_get(:@routes).reduce(0) do |current_max, route|
          route_length = route.conditions[:path_info].source.to_s.size
          route_length > current_max ? route_length : current_max
        end
        "Note: Anchored (\u2713) regexps are faster, e.g. /\\A.*\\Z/ or /^.*$/.\n\n" +
        routes.instance_variable_get(:@routes).map do |route|
          path_info = route.conditions[:path_info]
          anchored = ::Rack::Mount::Utils.regexp_anchored?(path_info)
          anchored_ok = anchored ? "\u2713" : " "
          source = path_info.source
          "#{anchored_ok}  #{source.ljust(max_length)} => #{route.name}"
        end.join("\n")
      end

    end

  end

end