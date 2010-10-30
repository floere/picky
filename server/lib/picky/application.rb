# The Picky application wherein the indexing and querying is defined.
#
class Application
  class << self
    
    # Returns a configured tokenizer that
    # is used for indexing by default.
    # 
    def default_indexing options = {}
      indexing.default_tokenizer options
    end
    
    # Returns a configured tokenizer that
    # is used for querying by default.
    # 
    def default_querying options = {}
      querying.default_tokenizer options
    end
    
    # Routes.
    #
    delegate :route, :root, :to => :routing
    # Index, Field.
    #
    # TODO Rename category.
    #
    delegate :field, :to => :indexing
    def index *args; indexing.define_index *args; end
    
    # An application simply delegates to the routing to handle a request.
    #
    def call env
      routing.call env
    end
    def routing
      @routing ||= Routing.new
    end
    def indexing
      @indexing ||= Configuration::Indexes.new
    end
    def querying
      @queries ||= Configuration::Queries.new
    end
    
    # Finalize the subclass as soon as it
    # has finished loading.
    #
    # Note: finalize finalizes the routes.
    #
    attr_reader :apps
    def inherited app
      @apps ||= []
      @apps << app
    end
    def finalize_apps
      @apps.each &:finalize
    end
    def finalize
      routing.freeze
    end
    
    # TODO Add more info.
    #
    def to_s
      "#{self.name}:\n#{routing}"
    end
    
  end
end