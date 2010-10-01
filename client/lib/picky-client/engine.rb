require 'net/http'

module Picky
  # Frontend for the search client.
  #
  # Configure a search by passing the options in the initializer:
  #   * host
  #   * port
  #   * path
  #
  # TODO Rewrite such that instead of an http request we connect through tcp.
  # Or use EventMachine.
  #
  module Client

    class Base

      attr_accessor :host, :port, :path

      def initialize options = {}
        options = default_configuration.merge options

        @host = options[:host]
        @port = options[:port]
        @path = options[:path]
      end
      def default_configuration
        {}
      end
      def self.default_configuration options = {}
        define_method :default_configuration do
          options
        end
      end
      def default_params
        {}
      end
      def self.default_params options = {}
        options.stringify_keys! if options.respond_to?(:stringify_keys!)
        define_method :default_params do
          options
        end
      end
      
      # Merges the given params, overriding the defaults.
      #
      def defaultize params = {}
        default_params.merge params
      end
      
      # Searches the index. Use this method.
      #
      # Returns a hash. Extend with Convenience.
      #
      def search params = {}
        return {} unless params[:query] && !params[:query].empty?
        
        send_search params
      end
      
      # Sends a search to the configured address.
      #
      def send_search params = {}
        params = defaultize params
        Net::HTTP.get self.host, "#{self.path}?#{params.to_query}", self.port
      end

    end

    class Full < Base
      default_configuration :host => 'localhost', :port => 4000, :path => '/searches/full'

      # Full needs to deserialize the results.
      #
      def send_search params = {}
        Serializer.deserialize super(params)
      end

    end

    class Live < Base
      default_configuration :host => 'localhost', :port => 4000, :path => '/searches/live'
    end

  end
end

# Extend hash with to_query method.
#
begin
  require 'active_support/core_ext/object/to_query'
rescue LoadError
  
end
class Hash
  def to_query namespace = nil
    collect do |key, value|
      value.to_query(namespace ? "#{namespace}[#{key}]" : key)
    end.sort * '&'
  end
end