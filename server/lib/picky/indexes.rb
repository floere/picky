# Holds all indexes and provides operations
# for extracting and working on them.
#
# Delegates a number of operations to the
# indexes.
#
class Indexes

  attr_reader :indexes,
              :index_mapping

  delegate :size,
           :each,
           :to => :indexes

  each_delegate :reindex,
                :to => :indexes

  def initialize
    clear
  end

  # Return the Indexes instance.
  #
  def self.instance
    @instance ||= new
  end

  instance_delegate :clear,
                    :register,
                    :reindex,
                    :[],
                    :to_s,
                    :size,
                    :each

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
  def self.register index
    self.instance.register index
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