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
    class << self
      attr_accessor :after
    end

    def initialize app
      @app = app

      @requests            = 0
      @quit_after_requests = self.class.after || 50
    end

    # #call interface method.
    #
    # Harakiri is a middleware, so it forwards the the app or
    # the next middleware after checking if it is time to honorably retire.
    #
    def call env
      harakiri
      @app.call env
    end

    # Checks to see if it is time to honorably retire.
    #
    # If yes, kills itself (Unicorn will answer the request, honorably).
    #
    # Note: Sends its process a QUIT signal if it is time.
    #
    def harakiri
      @requests = @requests + 1
      Process.kill(:QUIT, Process.pid) if harakiri?
    end

    # Is it time to honorably retire?
    #
    def harakiri?
      @requests >= @quit_after_requests
    end

  end

end