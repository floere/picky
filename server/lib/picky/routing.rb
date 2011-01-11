require 'rack/mount'

# 
#
class Routing # :nodoc:all
  
  @@defaults = {
    query_key:    'query'.freeze,
    offset_key:   'offset'.freeze,
    content_type: 'application/octet-stream'.freeze
  }
  
  def initialize
    @defaults = @@defaults.dup
  end
  
  # 
  #
  def reset_routes
    @routes = Rack::Mount::RouteSet.new
  end
  def routes
    @routes || reset_routes
  end
  def freeze
    routes.freeze
  end
  
  # Routing simply delegates to the route set to handle a request.
  #
  def call env
    routes.call env
  end
  
  #
  #
  def route options = {}
    mappings, route_options = split options
    mappings.each do |url, query|
      route_one url, query, route_options
    end
  end
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
    raise TargetQueryNilError.new(url) unless query
    query.tokenizer = @defaults[:tokenizer] if @defaults[:tokenizer]
    routes.add_route generate_app(query, route_options), default_options(url, route_options)
  end
  class TargetQueryNilError < StandardError
    def initialize url
      @url = url
    end
    def to_s
      "Routing for #{@url.inspect} was defined with a nil query object."
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
    
    options.delete :content_type # TODO
    
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
  
  # Generates a rack app for the given query.
  #
  def generate_app query, options = {}
    query_key    = options[:query_key]    || @defaults[:query_key]
    content_type = options[:content_type] || @defaults[:content_type]
    lambda do |env|
      params  = Rack::Request.new(env).params
      
      results = query.search_with_text *extracted(params)
      
      PickyLog.log results.to_log(params[query_key])
      
      respond_with results.to_response, content_type
    end
  end
  UTF8_STRING = 'UTF-8'.freeze
  def extracted params
    [
      # query is encoded in ASCII
      #
      params[@defaults[:query_key]]  && params[@defaults[:query_key]].force_encoding(UTF8_STRING),
      params[@defaults[:offset_key]] && params[@defaults[:offset_key]].to_i || 0
    ]
  end
  def respond_with response, content_type
    [200, { 'Content-Type' => content_type, 'Content-Length' => response.size.to_s }, [response]]
  end
  
  # Setup a route that answers using the given app.
  #
  def answer url = nil, app = nil
    routes.add_route (app || STATUSES[200]), default_options(url)
  end
  
  # Returns a regular expression for the url.
  #
  def normalized url
    url.respond_to?(:to_str) ? %r{#{url}} : url
  end
  
  # Returns true if there are no routes defined.
  #
  def empty?
    routes.length.zero?
  end
  
  # TODO Beautify.
  #
  def to_s
    routes.instance_variable_get(:@routes).map do |route|
      path_info = route.conditions[:path_info]
      anchored = Rack::Mount::Utils.regexp_anchored?(path_info)
      anchored_ok = anchored ? "\u2713" : " "
      "#{anchored_ok}  #{path_info.source}"
    end.join "\n"
  end
  
end