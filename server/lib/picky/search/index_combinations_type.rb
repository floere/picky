module Picky

  class Search

    # Returns the right combinations strategy for
    # a number of query indexes.
    #
    # Currently it isn't possible using Memory and Redis etc.
    # indexes in the same query index group.
    #
    # Picky will raise a Query::Indexes::DifferentTypesError.
    #
    @@mapping = {
      Indexes::Memory => Query::Combinations::Memory,
      Indexes::Redis  => Query::Combinations::Redis
    }
    def combinations_type_for index_definitions_ary # :nodoc:
      index_types = extract_index_types index_definitions_ary
      !index_types.empty? && @@mapping[*index_types] || Query::Combinations::Memory
    end
    def extract_index_types index_definitions_ary # :nodoc:
      index_types = index_definitions_ary.map(&:class)
      index_types.uniq!
      check_index_types index_types
      index_types
    end
    def check_index_types index_types # :nodoc:
      raise_different index_types if index_types.size > 1
    end
    # Currently it isn't possible using Memory and Redis etc.
    # indexes in the same query index group.
    #
    class DifferentTypesError < StandardError # :nodoc:all
      def initialize types
        @types = types
      end
      def to_s
        "Currently it isn't possible to mix #{@types.join(" and ")} Indexes in the same Search instance."
      end
    end
    def raise_different index_types # :nodoc:
      raise DifferentTypesError.new(index_types)
    end

  end

end