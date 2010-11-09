# Comfortable API convenience class, splits methods to indexes.
#
class Types
  
  attr_reader :types, :type_mapping
  
  delegate :reload,
           :load_from_cache,
           :to => :@indexes
  
  delegate :check_caches,
           :find,
           :generate_cache_only,
           :generate_index_only,
           :index,
           :index_for_tests,
           :to => :@indexings
  
  def initialize
    @types = []
    @type_mapping = {}
    
    @indexes   = Index::Types.new
    @indexings = Indexing::Types.new
  end
  
  def register type
    self.types << type
    self.type_mapping[type.name] = type
    
    @indexings.register type.indexing
    @indexes.register   type.index # TODO Even necessary?
  end
  
  def [] name
    name = name.to_sym
    
    self.type_mapping[name]
  end
  
end