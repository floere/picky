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
    grid      = options[:grid] || raise("Grid size needs to be given to a location")
    precision = options[:precision]
    
    define_category name, options do |indexing, indexed|
      indexing.source    = Sources::Wrappers::Location.new indexing, grid: grid, precision: precision
      indexing.tokenizer = Tokenizers::Index.new
      # indexing.partial = Partial::None.new
      
      exact_bundle    = Indexed::Wrappers::Bundle::Location.new indexed.exact, grid: grid
      indexed.exact   = exact_bundle
      indexed.partial = exact_bundle
    end
  end
  alias location define_location
  
end