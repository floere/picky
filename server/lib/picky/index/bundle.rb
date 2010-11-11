module Index
  # A Bundle is a number of indexes
  # per [index, category] combination.
  #
  # At most, there are three indexes:
  # * *core* index (always used)
  # * *weights* index (always used)
  # * *similarity* index (used with similarity)
  # 
  # In Picky, indexing is separated from the index
  # handling itself through a parallel structure.
  #
  # Both use methods provided by this base class, but
  # have very different goals:
  #
  # * *Indexing*::*Bundle* is just concerned with creating index files
  #   and providing helper functions to e.g. check the indexes.
  #
  # * *Index*::*Bundle* is concerned with loading these index files into
  #   memory and looking up search data as fast as possible.
  #
  class Bundle
    
    attr_reader   :identifier, :files
    attr_accessor :index, :weights, :similarity, :similarity_strategy
    
    delegate :[], :[]=, :clear, :to => :index
    
    def initialize name, category, index, similarity_strategy
      @identifier = "#{index.name}: #{name} #{category.name}"
      # TODO inject files.
      #
      # TODO Move Files somewhere. Shared?
      #
      # Files and the identifier are parametrized, the rest is not!
      #
      @files = Files.new name, category.name, index.name
      
      @index      = {}
      @weights    = {}
      @similarity = {}
      
      @similarity_strategy = similarity_strategy
    end
    
    # Get a list of similar texts.
    #
    def similar text
      code = similarity_strategy.encoded text
      code && @similarity[code] || []
    end
    
  end
end