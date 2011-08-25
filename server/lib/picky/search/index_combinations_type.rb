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
      Backends::Memory => Query::Combinations::Memory,
      Backends::Redis  => Query::Combinations::Redis
    }
    def combinations_type_for index_definitions_ary # :nodoc:
      backend_types = extract_backend_types index_definitions_ary
      !backend_types.empty? && @@mapping[*backend_types] || Query::Combinations::Memory
    end
    def extract_backend_types index_definitions_ary # :nodoc:
      backend_types = index_definitions_ary.map(&:backend).map(&:class)
      backend_types.uniq!
      check_backend_types backend_types
      backend_types
    end
    def check_backend_types backend_types # :nodoc:
      raise_different backend_types if backend_types.size > 1
    end
    # Currently it isn't possible using Memory and Redis etc.
    # indexes in the same query index group.
    #
    class DifferentTypesError < StandardError # :nodoc:all
      def initialize types
        @types = types
      end
      def to_s
        "Currently it isn't possible to mix Indexes with backends #{@types.join(" and ")} in the same Search instance."
      end
    end
    def raise_different backend_types # :nodoc:
      raise DifferentTypesError.new(backend_types)
    end

  end

end