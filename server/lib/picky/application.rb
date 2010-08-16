class Application
  
  # Sets the defaults and delegates routing to
  # the routes.
  #
  def self.routing default_options = nil, &block
    routes.defaults default_options if default_options
    routes.define_using &block
  end
  
  # An application simply delegates to the route set to handle a request.
  #
  def self.call env
    routes.call env
  end
  
  #
  #
  def self.routes
    @routes || reset_routes
  end
  def self.reset_routes
    @routes = Routing.new
  end
  
end