module Indexed

  # Registers the indexes held at runtime, for queries.
  #
  class Indexes

    attr_reader :indexes, :index_mapping

    each_delegate :load_from_cache,
                  :to => :indexes

    def initialize
      clear
    end

    def to_s
      indexes.indented_to_s
    end

    # Clears the indexes and the mapping.
    #
    def clear
      @indexes       = []
      @index_mapping = {}
    end

    # Reloads all indexes, one after another,
    # in the order they were added.
    #
    def reload
      load_from_cache
    end

    # Registers an index with the indexes.
    #
    def register index
      self.indexes << index
      self.index_mapping[index.name] = index
    end

    # Load each index, and analyze it.
    #
    # Returns a hash with the findings.
    #
    def analyze
      result = {}
      self.indexes.each do |index|
        index.analyze result
      end
      result
    end

    # Extracts an index, given its identifier.
    #
    def [] identifier
      index_mapping[identifier.to_sym]
    end

  end

end