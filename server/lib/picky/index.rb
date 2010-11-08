# This class defines the indexing and index API.
#
# Note: An Index holds both an Index::Type and an Indexing::Type.
#
class Index
  
  # TODO Delegation.
  #
  
  attr_reader :indexing, :index
  
  def initialize name, source, options = {}
    @indexing = Indexing::Type.new name, source, options
    @index    = Index::Type.new    name, options
    
    Indexes.register @index
  end
  
  # API.
  #
  # TODO Spec! Doc!
  #
  def category name, options = {}
    name = name.to_sym
    
    indexing.add_category name, options
    index.add_category    name, options
  end
  def location name, options = {}
    grid      = options.delete :grid
    precision = options.delete :precision
    
    options[:tokenizer] ||= Tokenizers::Index.new # TODO Or a specific location tokenizer.
    
    new_category = category name, options
    :source => Sources::Wrappers::Location.new(source, grid:2), :tokenizer => Tokenizers::Index.new
  end
  
end