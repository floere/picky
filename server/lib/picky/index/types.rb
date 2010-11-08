module Index
  
  class Types
    
    attr_reader :types, :type_mapping
    
    each_delegate :load_from_cache,
                  :to => :types
    
    def initialize
      clear
    end
    
    # TODO Spec.
    #
    def clear
      @types        = []
      @type_mapping = {}
    end
    
    # TODO Spec.
    #
    def reload
      load_from_cache
    end
    
    # TODO Spec
    #
    def register type
      self.types << type
      self.type_mapping[type.name] = type
    end
    def [] name
      name = name.to_sym
      
      type_mapping[name]
    end
    
  end
  
end