module Indexing
  
  class Indexes
    
    attr_reader :indexes
    
    each_delegate :take_snapshot,
                  :generate_caches,
                  :backup_caches,
                  :restore_caches,
                  :check_caches,
                  :clear_caches,
                  :create_directory_structure,
                  :to => :indexes
    
    def initialize
      clear
    end
    
    # TODO Spec.
    #
    def clear
      @indexes = []
    end
    
    # TODO Spec. Superclass?
    #
    def register index
      self.indexes << index
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
      Cores.forked self.indexes, { randomly: randomly } do |an_index|
        an_index.index
        an_index.cache
      end
      timed_exclaim "INDEXING FINISHED."
    end
    
    # For testing.
    #
    def index_for_tests
      take_snapshot
      
      self.indexes.each do |index|
        an_index.index
        an_index.cache
      end
    end
    
    # TODO Spec
    #
    def generate_index_only index_name, category_name
      found = find index_name, category_name
      found.index if found
    end
    def generate_cache_only index_name, category_name
      found = find index_name, category_name
      found.generate_caches if found
    end
    
    # TODO Spec
    #
    def find index_name, category_name
      index_name     = index_name.to_sym
      
      indexes.each do |index|
        next unless index.name == index_name
        
        found = index.categories.find category_name
        return found if found
      end
      
      raise %Q{Index "#{index_name}" not found. Possible indexes: "#{indexes.map(&:name).join('", "')}".}
    end
    
  end
end