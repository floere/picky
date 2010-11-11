module Indexed
  
  class Indexes
    
    attr_reader :indexes, :index_mapping
    
    each_delegate :load_from_cache,
                  :to => :indexes
    
    def initialize
      clear
    end
    
    # TODO Spec.
    #
    def clear
      @indexes       = []
      @index_mapping = {}
    end
    
    # TODO Spec.
    #
    def reload
      load_from_cache
    end
    
    # TODO Spec
    #
    def register index
      self.indexes << index
      self.index_mapping[index.name] = index
    end
    def [] name
      name = name.to_sym
      
      index_mapping[name]
    end
    
  end
  
end