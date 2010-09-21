require 'rack/mount'

# 
#
class Routing
  
  @@defaults = {
    :query_key    => 'query'.freeze,
    :offset_key   => 'offset'.freeze,
    :content_type => 'application/octet-stream'.freeze
  }
  
  def initialize
    @defaults = @@defaults.dup
  end
  
  # #
  # #
  # def define_using &block
  #   reset_routes
  #   instance_eval &block
  #   routes.freeze
  # end
  
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
  
  # Set the defaults.
  # 
  # Options are:
  #  * :query_key  => :query # default
  #  * :offset_key => :offset # default
  #  
  #  * :tokenizer  => Tokenizers::Query.new # default
  #
  def defaults options = {}
    @defaults[:query_key]    = options[:query_key].to_s  if options[:query_key]
    @defaults[:offset_key]   = options[:offset_key].to_s if options[:offset_key]
    
    @defaults[:tokenizer]    = options[:tokenizer]       if options[:tokenizer]
    @defaults[:content_type] = options[:content_type]    if options[:content_type]
    
    @defaults
  end
  
  #
  #
  def route url, query, route_options = {}
    query.tokenizer = @defaults[:tokenizer] if @defaults[:tokenizer]
    routes.add_route generate_app(query, route_options), default_options(url, route_options)
  end
  #
  #
  def live url, *indexes_and_options
    route_options = Hash === indexes_and_options.last ? indexes_and_options.pop : {}
    route url, Query::Live.new(*indexes_and_options), route_options
  end
  #
  #
  def full url, *indexes_and_options
    route_options = Hash === indexes_and_options.last ? indexes_and_options.pop : {}
    route url, Query::Full.new(*indexes_and_options), route_options
  end
  #
  #
  def root status
    answer '^/$', STATUSES[status]
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
    options = { :request_method => 'GET' }.merge route_options
    
    options[:path_info] = %r{#{url}} if url
    
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
      
      PickyLog.log results.to_log(params[query_key]) # TODO Save the original query in the results object.
      
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
    [200, { 'Content-Type' => content_type, 'Content-Length' => response.size.to_s, }, [response]]
  end
  
  # Setup a route that answers using the given app.
  #
  def answer url = nil, app = nil
    routes.add_route (app || STATUSES[200]), default_options(url)
  end
  
end