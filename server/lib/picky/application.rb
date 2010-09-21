class Application
  
  # An application simply delegates to the routing to handle a request.
  #
  def self.routing
    @routing ||= Routing.new
  end
  def self.call env
    routing.call env
  end
  
  # TODO Multiple indexes?
  #
  def self.indexes &block
    indexes_configuration.instance_eval &block
    # TODO Uglyyyyyy.
    ::Indexes.configuration = indexes_configuration
    ::Indexes.setup # TODO Think about setup/reload.
  end
  def self.indexes_configuration
    @indexes || reset_indexes
  end
  def self.reset_indexes
    @indexes = Configuration::Indexes.new # Is instance a problem?
  end
  
  # TODO Multiple Queries?
  #
  def self.queries &block
    queries_configuration.instance_eval &block
    routing.freeze
  end
  def self.queries_configuration
    @queries || reset_queries
  end
  def self.reset_queries
    @queries = Configuration::Queries.new routing # Is instance a problem?
  end
  
end