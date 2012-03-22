# Ruby Search Client Frontend for the Picky search engine.
#
# === Usage
#
# ==== 1. Set up search clients.
#
#   # Create search client instances e.g. in your development.rb, production.rb etc.
#   #
#   # Use the right host, port where your Picky server runs. Then, choose a URL path as defined
#   # in your <tt>app/application.rb</tt> in the server.
#   #
#   BookSearch = Picky::Client.new :host => 'localhost', :port => 8080, :path => '/books'
#
# ==== 2. Get results.
#
#   # Then, in your search methods, call #search.
#   #
#   # You will get back a Hash with categorized results.
#   #
#   results = BookSearch.search 'my query', :offset => 10
#
# ==== 3. Work with the results.
#
#   # To make the Hash more useful, extend it with a few convenience methods.
#   # See Picky::Convenience.
#   #
#   results.extend Picky::Convenience
#
#   # One of the added Methods is:
#   #   populate_with(ModelThatSupportsFind, &optional_block_where_you_get_model_instance_and_you_can_render)
#   # This adds the rendered models to the results Hash.
#   #
#   results.populate_with Book do |book|
#     book.to_s
#   end
#
# ==== 4. Last step is encoding it back into JSON.
#
#   # Encode the results in JSON and return it to the Javascript Client (or your frontend).
#   #
#   ActiveSupport::JSON.encode results
#
# Note: The client might be rewritten such that instead of an http request it connects through tcp/0mq.
#
require 'net/http'

module Picky

  class Client
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

    default_configuration :host => 'localhost', :port => 8080, :path => '/searches'

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
    @@parser_options = { :symbolize_keys => true }
    def search query, params = {}
      return {} unless query && !query.empty?

      ::Yajl::Parser.parse search_unparsed(query, params), @@parser_options
    end
    # Use this method for live queries – they can pass the
    # JSON string with the results through without parsing.
    #
    def search_unparsed query, params = {}
      return '' unless query && !query.empty?

      send_search params.merge :query => query
    end

    # Sends a search to the configured address.
    #
    # Note: For live queries, parsing is actually not really necessary.
    #
    def send_search params = {}
      params = defaultize params
      ::Net::HTTP.get self.host, "#{self.path}?#{params.to_query}", self.port
    end

  end

end

# Extend object with to_query method.
#
require 'active_support/core_ext/object/to_query'
