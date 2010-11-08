# This class defines the indexing and index API.
#
# Note: A Type holds both an Index::Type and an Indexing::Type.
#
class Type
  
  # TODO Delegation.
  #
  
  attr_reader :name, :indexing, :index
  
  def initialize name, source, options = {}
    @name     = name
    @indexing = Indexing::Type.new name, source, options
    @index    = Index::Type.new    name, options
    
    # Centralized registry.
    #
    Indexes.register self
  end
  
  # API.
  #
  # TODO Spec! Doc!
  #
  def category name, options = {}
    name = name.to_sym
    
    indexing.add_category name, options
    index.add_category    name, options
    
    self
  end
  # def location name, options = {}
  #   grid      = options.delete :grid
  #   precision = options.delete :precision
  #   
  #   options[:index_tokenizer] ||= Tokenizers::Index.new # TODO Or a specific location tokenizer.
  #   options[:query_tokenizer] ||= Tokenizers::Query.new # TODO Or a specific location tokenizer.
  #   options[:source_wrapper]  ||= Sources::Wrappers::Location.new(options)
  #   
  #   new_category = category name, options
  #   :source => Sources::Wrappers::Location.new(source, grid:2), :tokenizer => Tokenizers::Index.new
  # end
  
end