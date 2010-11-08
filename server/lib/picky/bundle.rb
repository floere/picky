class Bundle
  
  attr_reader   :identifier, :category, :files
  attr_accessor :index, :weights, :similarity, :similarity_strategy
  
  delegate :[], :[]=, :clear, :to => :index
  
  def initialize name, category, type, similarity_strategy
    @identifier = "#{name}: #{type.name} #{category.name}"
    
    @index      = {}
    @weights    = {}
    @similarity = {}
    
    @similarity_strategy = similarity_strategy
    
    # TODO inject files.
    #
    # TODO Move Files somewhere. Shared?
    #
    @files = Index::Files.new name, category.name, type.name
  end
  
  # Get a list of similar texts.
  #
  def similar text
    code = similarity_strategy.encoded text
    code && @similarity[code] || []
  end
  
end