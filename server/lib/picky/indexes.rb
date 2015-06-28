module Picky

  # Holds all indexes and provides operations
  # for extracting and working on them.
  #
  # Forwards a number of operations to the
  # indexes.
  #
  class Indexes

    attr_reader :indexes,
                :index_mapping

    forward :size, :each, :map, :to => :indexes
    each_forward :reindex, :to => :indexes
    instance_forward :clear,
                     :clear_indexes,
                     :register,
                     :reindex,
                     :[],
                     :to_s,
                     :size,
                     :each,
                     :each_category

    def initialize *indexes
      clear_indexes
      indexes.each { |index| register index }
    end

    # Return the Indexes instance.
    #
    def self.instance
      @instance ||= new
    end
    def self.identifier
      name
    end

    # Clears the indexes and the mapping.
    #
    def clear_indexes
      @indexes       = []
      @index_mapping = Hash.new
    end
    
    # Tries to optimize the memory usage of the indexes.
    #
    def optimize_memory array_references = Hash.new
      dedup = Picky::Optimizers::Memory::ArrayDeduplicator.new
      @indexes.each do |index|
        index.optimize_memory array_references
      end
    end
    def self.optimize_memory array_references = Hash.new
      self.instance.optimize_memory array_references
    end

    # Registers an index with the indexes.
    #
    def register index
      # TODO Do not store duplicate indexes.
      #
      # self.indexes.delete_if { |existing| existing.name == index.name }
      self.indexes << index
      self.index_mapping[index.name] = index
    end
    def self.register index
      self.instance.register index
    end

    # Extracts an index, given its identifier.
    #
    def [] identifier
      index_name = identifier.intern
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

end