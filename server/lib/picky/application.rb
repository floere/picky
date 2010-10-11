# The Picky application wherein the indexing and querying is defined.
#
class Application
  class << self
    
    # An application simply delegates to the routing to handle a request.
    #
    def call env
      finalized_routing.call env
    end
    
    # Freezes the routes.
    #
    def finalize
      routing.freeze
    end
    # Returns a finalized routing.
    #
    def finalized_routing
      @finalized_routing ||= routing.freeze
    end
    def routing
      @routing ||= Routing.new
    end
    # Routes.
    #
    delegate :route, :root, :to => :routing
    
    # 
    #
    def indexing
      @indexing ||= Configuration::Indexes.new
    end
    def index *args
      self.type *args
    end
    delegate :type, :field, :to => :indexing
    
    #
    #
    def querying
      @queries ||= Configuration::Queries.new
    end
    
  end
end