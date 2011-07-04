# Holds all indexes and provides operations
# for extracting and working on them.
#
# Delegates a number of operations to the
# indexes.
#
class Indexes
  
  # Return the Indexes instance.
  #
  def self.instance
    @instance ||= new
  end
  
  attr_reader :indexes,
              :index_mapping
  
  instance_delegate :clear,
                    :register,
                    :[],
                    :to_s,
                    :size,
                    :each
              
  delegate :size,
           :each,
           :to => :indexes
  
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