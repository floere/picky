# The Picky application wherein the indexing and querying is defined.
#
# TODO Documentation.
#
class Application
  
  class << self
    
    # API
    #
    
    # Returns a configured tokenizer that
    # is used for indexing by default.
    # 
    def default_indexing options = {}
      Tokenizers::Index.default = Tokenizers::Index.new(options)
    end
    
    # Returns a configured tokenizer that
    # is used for querying by default.
    # 
    def default_querying options = {}
      Tokenizers::Query.default = Tokenizers::Query.new(options)
    end
    
    # Returns a new index frontend for configuring the index.
    #
    def index *args
      IndexAPI.new *args
    end
    
    # Routes.
    #
    delegate :route, :root, :to => :routing
    
    #
    # API
    
    
    # An application simply delegates to the routing to handle a request.
    #
    def call env
      routing.call env
    end
    def routing
      @routing ||= Routing.new
    end
    
    # Finalize the subclass as soon as it
    # has finished loading.
    #
    attr_reader :apps
    def initialize_apps
      @apps ||= []
    end
    def inherited app
      initialize_apps
      apps << app
    end
    def finalize_apps
      initialize_apps
      apps.each &:finalize
    end
    # Finalizes the routes.
    #
    def finalize
      routing.freeze
    end
    
    # TODO Add more info if possible.
    #
    def to_s
      "#{self.name}:\n#{routing}"
    end
    
  end
end