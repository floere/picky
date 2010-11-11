module Rack
  
  # Simple Rack Middleware to kill Unicorns after X requests.
  #
  # Use as follows in e.g. your rackup File:
  #
  #   Rack::Harakiri.after = 100
  #   use Rack::Harakiri
  #
  # Then the Unicorn will commit suicide after 100 requests (50 is the default).
  #
  # The Master Unicorn process forks a new child Unicorn to replace the old one.
  #
  class Harakiri
    
    # Set the amount of requests before the Unicorn commits Harakiri.
    #
    cattr_accessor :after
    attr_reader :quit_after_requests
    
    def initialize app
      @app = app
      
      @requests            = 0
      @quit_after_requests = self.class.after || 50
    end
    
    # Harakiri is a middleware, so it passes the call on after checking if it
    # is time to honorably retire.
    #
    def call env
      harakiri
      @app.call env
    end
    
    # Checks to see if it is time to honorably retire.
    #
    # If yes, kills itself (Unicorn will answer the request, honorably).
    #
    def harakiri
      @requests = @requests + 1
      Process.kill(:QUIT, Process.pid) if @requests >= @quit_after_requests
    end
    
  end
end