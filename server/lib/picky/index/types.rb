module Index
  
  class Types
    
    attr_reader :types, :type_mapping
    
    each_delegate :take_snapshot,
                  :generate_caches,
                  :load_from_cache,
                  :backup_caches,
                  :restore_caches,
                  :check_caches,
                  :clear_caches,
                  :create_directory_structure,
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
    
    # Runs the indexers in parallel (index + cache).
    #
    # TODO Spec.
    #
    def index randomly = true
      take_snapshot
      
      # Run in parallel.
      #
      timed_exclaim "INDEXING USING #{Cores.max_processors} PROCESSORS, IN #{randomly ? 'RANDOM' : 'GIVEN'} ORDER."
      Cores.forked self.types, { randomly: randomly } do |type|
        type.index
        type.cache
      end
      timed_exclaim "INDEXING FINISHED."
    end
    
    # TODO Spec
    #
    def find type_name, category_name
      type_name     = type_name.to_sym
      
      types.each do |type|
        next unless type.name == type_name
        
        found = type.categories.find category_name
        return found if found
      end
    end
    
    # TODO Spec
    #
    def generate_index_only type_name, field_name
      found = find type_name, field_name
      found.index if found
    end
    def generate_cache_only type_name, category_name
      found = find type_name, field_name
      found.generate_caches if found
    end
    
  end
  
  # Alias # TODO Move?
  #
  ::Indexes = Types.new
end