module Picky

  class TestClient < Client

    attr_reader :request

    #
    #
    # Example:
    #   Picky::TestClient.new(BookSearch, :path => '/books')
    #
    def initialize rack_app, options = {}
      super options

      @request = ::Rack::MockRequest.new rack_app
    end

    # Wraps the search method to always extend the result with Convenience.
    #
    def search query, params = {}
      super.extend Convenience
    end

    # Backend method that we override to not send a real search.
    #
    def send_search params = {}
      params = defaultize params

      request.get("#{self.path}?#{params.to_query}").body
    end

  end

end