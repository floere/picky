module Indexing
  
  class Types
    
    attr_reader :types
    
    each_delegate :take_snapshot,
                  :generate_caches,
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
      @types = []
    end
    
    # TODO Spec. Superclass?
    #
    def register type
      self.types << type
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
    
    # For testing.
    #
    def index_for_tests
      take_snapshot
      
      self.types.each do |type|
        type.index
        type.cache
      end
    end
    
    # TODO Spec
    #
    def generate_index_only type_name, category_name
      found = find type_name, category_name
      found.index if found
    end
    def generate_cache_only type_name, category_name
      found = find type_name, category_name
      found.generate_caches if found
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
      
      raise %Q{Index "#{type_name}" not found. Possible indexes: "#{types.map(&:name).join('", "')}".}
    end
    
  end
end