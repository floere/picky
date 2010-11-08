# Comfortable API convenience class, splits methods to indexes.
#
class Types
  
  attr_reader :types, :type_mapping
  
  delegate :reload,
           :load_from_cache,
           :to => :@indexes
  
  delegate :find,
           :index,
           :index_for_tests,
           :generate_index_only,
           :generate_cache_only,
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