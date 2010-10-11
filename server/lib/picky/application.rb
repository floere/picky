# The Picky application wherein the indexing and querying is defined.
#
class Application
  
  # An application simply delegates to the routing to handle a request.
  #
  def self.routing
    @routing ||= Routing.new
  end
  def self.call env
    routing.call env
  end
  # Routes.
  #
  delegate :defaults, :route, :live, :full, :root, :default, :to => :routing
  
  # 
  #
  def self.indexing
    @indexing ||= Configuration::Indexes.new
  end
  
  #
  #
  def self.querying
    @queries ||= Configuration::Queries.new
  end
  
end