# This class defines the indexing and index API.
#
# Note: An Index holds both an *Indexed*::*Index* and an *Indexing*::*Type*.
#
class IndexAPI
  
  # TODO Delegation.
  #
  
  attr_reader :name, :indexing, :indexed
  
  def initialize name, source, options = {}
    @name     = name
    @indexing = Indexing::Index.new name, source, options
    @indexed  = Indexed::Index.new  name, options
    
    # Centralized registry.
    #
    Indexes.register self
  end
  
  # API.
  #
  # TODO Spec! Doc!
  #
  def define_category category_name, options = {}
    category_name = category_name.to_sym
    
    indexing_category = indexing.add_category category_name, options
    indexed_category  = indexed.add_category  category_name, options
    
    yield indexing_category, indexed_category if block_given?
    
    self
  end
  alias category define_category
  
  # TODO Rewrite wrap_exact, wrap_source ?
  #
  def define_location name, options = {}
    grid      = options[:radius] || raise("Option :radius needs to be set on define_location, it defines the search radius.")
    precision = options[:precision]
    
    options = { partial: Partial::None.new }.merge options
    
    define_category name, options do |indexing, indexed|
      indexing.source    = Sources::Wrappers::Location.new indexing, grid: grid, precision: precision
      indexing.tokenizer = Tokenizers::Index.new
      
      exact_bundle    = Indexed::Wrappers::Bundle::Location.new indexed.exact, grid: grid, precision: precision
      indexed.exact   = exact_bundle
      indexed.partial = exact_bundle
    end
  end
  alias location define_location
  
  # Options
  # * radius (in km).
  #
  def define_map_location name, options = {}
    radius = options[:radius] || raise("Option :radius needs to be set on define_map_location, it defines the search radius.")
    
    # The radius is given as if all the locations were on the equator.
    #
    # TODO Need to recalculate since not many locations are on the equator ;) This is just a prototype.
    #
    # This calculates km -> longitude (degrees).
    #
    # A degree on the equator is equal to ~111,319.9 meters.
    # So a km on the equator is equal to 0.00898312 degrees.
    #
    options[:radius] = radius * 0.00898312
    
    define_location name, options
  end
end