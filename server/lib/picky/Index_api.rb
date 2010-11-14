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
  # Rename?
  #
  def category category_name, options = {}
    category_name = category_name.to_sym
    
    indexing.add_category category_name, options
    indexed.add_category  category_name, options
    
    self
  end
  # def location name, options = {}
  #   grid      = options[:grid]
  #   precision = options[:precision]
  #   
  #   new_category = category name, options
  #   source = indexing.source
  #   new_category.source    = Sources::Wrappers::Location.new source, grid: grid, precision: precision
  #   new_category.tokenizer = Tokenizers::Index.new
  # end
  
end