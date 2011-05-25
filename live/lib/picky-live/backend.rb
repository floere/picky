require 'net/http'

# Ruby Live Interface to the Picky search engine.
#
class Backend

  attr_reader :host, :port, :path

  def initialize options = {}
    @host = options[:host] || 'localhost'
    @port = options[:port] || 8080
    @path = options[:path] || '/admin'
  end

  def get params = {}
    query_params = params.to_query
    query_params = "?#{query_params}" unless query_params.empty?
    Net::HTTP.get self.host, "#{self.path}#{query_params}", self.port
  end

  # Extend hash with to_query method.
  #
  require 'active_support/core_ext/object/to_query'

end