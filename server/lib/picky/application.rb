#
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
    
    # Create a new index for indexing and for querying.
    #
    # Parameters:
    # * name: The identifier of the index. Used:
    #   - to identify an index (e.g. by you in Rake tasks).
    #   - in the frontend to describe which index a result came from.
    #   - index directory naming (index/development/the_identifier/<lots of indexes>)
    # * source: The source the data comes from. See Sources::Base. # TODO Sources (all).
    #
    # Options:
    # * result_type: # TODO Rename.
    #
    def index name, source, options = {}
      IndexAPI.new name, source, options
    end
    
    # Routes.
    #
    delegate :route, :root, :to => :routing
    
    #
    # API
    
    
    # A Picky application implements the Rack interface.
    #
    # Delegates to its routing to handle a request.
    #
    def call env
      routing.call env
    end
    def routing # :nodoc:
      @routing ||= Routing.new
    end
    
    # Finalize the subclass as soon as it
    # has finished loading.
    #
    attr_reader :apps # :nodoc:
    def initialize_apps # :nodoc:
      @apps ||= []
    end
    def inherited app # :nodoc:
      initialize_apps
      apps << app
    end
    def finalize_apps # :nodoc:
      initialize_apps
      apps.each &:finalize
    end
    # Finalizes the routes.
    #
    def finalize # :nodoc:
      routing.freeze
    end
    
    # TODO Add more info if possible.
    #
    def to_s # :nodoc:
      "#{self.name}:\n#{routing}"
    end
    
  end
end