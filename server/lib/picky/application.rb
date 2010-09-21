class Application
  
  # An application simply delegates to the queries configuration to handle a request.
  #
  def self.call env
    queries_configuration.call env
  end
  
  #
  #
  def self.queries
    yield queries_configuration
  end
  def self.queries_configuration
    @queries || reset_queries
  end
  def self.reset_queries
    @queries = Configuration::Queries.new # Is instance a problem?
  end
  
  # #
  # #
  # def self.indexes
  #   yield indexes_configuration
  # end
  # def self.indexes_configuration
  #   @indexes || reset_indexes
  # end
  # def self.reset_indexes
  #   @indexes = Configuration::Indexes.new # Is instance a problem?
  # end
  
end