module Shared
  
  # A number of shared methods between
  #  * Indexed::Indexes
  #  * Indexing::Indexes 
  #
  module Indexes # :nodoc:all
    
    attr_reader :indexes,
                :index_mapping
    
    def initialize
      clear
    end
    
    # Clears the indexes and the mapping.
    #
    def clear
      @indexes       = []
      @index_mapping = {}
    end
    
    # Registers an index with the indexes.
    #
    def register index
      self.indexes << index
      self.index_mapping[index.name] = index
    end
    
    # Extracts an index, given its identifier.
    #
    def [] identifier
      index_name = identifier.to_sym
      index_mapping[index_name] || raise_not_found(index_name)
    end
    
    # Find a given index:category pair.
    #
    # TODO Phase out in 2.6.
    #
    def find index_name, category_name = nil
      index_name = index_name.to_sym

      indexes.each do |index|
        next unless index.name == index_name

        return index unless category_name

        found = index[category_name]
        return found if found
      end

      raise_not_found index_name
    end
    
    # Raises a not found for the index.
    #
    def raise_not_found index_name
      raise %Q{Index "#{index_name}" not found. Possible indexes: "#{indexes.map(&:name).join('", "')}".}
    end
    
    #
    #
    def to_s
      indexes.indented_to_s
    end
    
  end
  
end