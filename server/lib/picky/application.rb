# The Picky application wherein the indexing and querying is defined.
#
class Application
  class << self
    
    # Finalize the subclass as soon as it
    # has finished loading.
    #
    # Note: finalize finalizes the routes.
    #
    def inherited app
      @apps ||= []
      @apps << app
    end
    def finalize_apps
      @apps.each &:finalize
    end
    
    # An application simply delegates to the routing to handle a request.
    #
    def call env
      routing.call env
    end
    
    # Freezes the routes.
    #
    def finalize
      routing.freeze
    end
    def routing
      @routing ||= Routing.new
    end
    # Routes.
    #
    delegate :route, :root, :to => :routing
    
    # TODO Rename to default_indexing?
    #
    def indexing
      @indexing ||= Configuration::Indexes.new
    end
    def index *args
      self.type *args
    end
    delegate :type, :field, :to => :indexing
    
    # TODO Rename to default_querying?
    #
    def querying
      @queries ||= Configuration::Queries.new
    end
    
  end
end