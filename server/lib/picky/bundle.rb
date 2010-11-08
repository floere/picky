class Bundle
  
  attr_reader   :identifier, :category, :files
  attr_accessor :index, :weights, :similarity
  
  delegate :[], :[]=, :clear, :to => :index
  
  def initialize name, category, type
    @identifier = "#{name}: #{type.name} #{category.name}"
    
    @index      = {}
    @weights    = {}
    @similarity = {}
    
    # TODO inject files.
    #
    # TODO Move Files somewhere. Shared?
    #
    @files = Index::Files.new name, category.name, type.name
  end
  
end