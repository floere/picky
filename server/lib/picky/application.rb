# The Picky application wherein the indexing and querying is defined.
#
class Application
  class << self
    
    # An application simply delegates to the routing to handle a request.
    #
    def routing
      @routing ||= Routing.new
    end
    def call env
      routing.call env
    end
    # Routes.
    #
    delegate :route, :root, :to => :routing
    
    # 
    #
    def indexing
      @indexing ||= Configuration::Indexes.new
    end
    delegate :index, :field, :to => :indexing
    
    #
    #
    def querying
      @queries ||= Configuration::Queries.new
    end
    
  end
end