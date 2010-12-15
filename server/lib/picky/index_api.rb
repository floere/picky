# This class defines the indexing and index API that is exposed to the user.
# It provides a single front for both indexing and index options.
#
# Note: An Index holds both an *Indexed*::*Index* and an *Indexing*::*Type*.
#
class IndexAPI # :nodoc:all
  
  attr_reader :name, :indexing, :indexed
  
  # TODO Doc.
  #
  def initialize name, source, options = {}
    @name     = name
    @indexing = Indexing::Index.new name, source, options
    @indexed  = Indexed::Index.new  name, options
    
    # Centralized registry.
    #
    Indexes.register self
  end
  
  # TODO Doc.
  #
  def define_category category_name, options = {}
    category_name = category_name.to_sym
    
    indexing_category = indexing.define_category category_name, options
    indexed_category  = indexed.define_category  category_name, options
    
    yield indexing_category, indexed_category if block_given?
    
    self
  end
  alias category define_category
  
  # Parameters:
  # * name: The name as used in #define_category.
  # * radius: The range (in km) around the query point which we search for results.
  #
  #        <---range---|
  #  -----|------------*------------|-----
  #
  # Options
  # * precision # Default 1 (20% error margin, very fast), up to 5 (5% error margin, slower) makes sense.
  #
  def define_location name, range, options = {}
    precision = options[:precision]
    
    options = { partial: Partial::None.new }.merge options
    
    define_category name, options do |indexing, indexed|
      indexing.source    = Sources::Wrappers::Location.new indexing, grid: range, precision: precision
      indexing.tokenizer = Tokenizers::Index.new
      
      exact_bundle    = Indexed::Wrappers::Bundle::Location.new indexed.exact, grid: range, precision: precision
      indexed.exact   = exact_bundle
      indexed.partial = exact_bundle # A partial token also uses the exact index.
    end
  end
  alias location define_location
  
  # Parameters:
  # * name: The name as used in #define_category.
  # * radius: The distance (in km) around the query point which we search for results.
  #
  # Note: Picky uses a square, not a circle.
  #
  #  -----------------------------
  #  |                           |
  #  |                           |
  #  |                           |
  #  |                           |
  #  |                           |
  #  |             *<-  radius ->|
  #  |                           |
  #  |                           |
  #  |                           |
  #  |                           |
  #  |                           |
  #  -----------------------------
  #
  # Options
  # * precision # Default 1 (20% error margin, very fast), up to 5 (5% error margin, slower) makes sense.
  #
  def define_map_location name, radius, options = {}
    # The radius is given as if all the locations were on the equator.
    #
    # TODO Need to recalculate since not many locations are on the equator ;) This is just a prototype.
    #
    # This calculates km -> longitude (degrees).
    #
    # A degree on the equator is equal to ~111,319.9 meters.
    # So a km on the equator is equal to 0.00898312 degrees.
    #
    define_location name, radius * 0.00898312, options
  end
end