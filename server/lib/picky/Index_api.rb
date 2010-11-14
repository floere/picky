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
  
  def define_location name, options = {}
    grid      = options[:grid]
    precision = options[:precision]
    
    define_category name, options do |indexing, _|
      indexing.source    = Sources::Wrappers::Location.new indexing.source, grid: grid, precision: precision
      indexing.tokenizer = Tokenizers::Index.new
    end
  end
  alias location define_location
  
end