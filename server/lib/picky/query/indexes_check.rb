module Picky

  module Query

    # TODO Remove.
    #
    class IndexesCheck

      class << self

        # Returns the right combinations strategy for
        # a number of query indexes.
        #
        # Currently it isn't possible using Memory and Redis etc.
        # indexes in the same query index group.
        #
        # Picky will raise a Query::Indexes::DifferentTypesError.
        #
        def check_backend_types index_definitions_ary # :nodoc:
          backend_types = index_definitions_ary.map(&:backend).map(&:class)
          backend_types.uniq!
          raise_different backend_types if backend_types.size > 1
          backend_types
        end
        def raise_different backend_types # :nodoc:
          raise DifferentTypesError.new(backend_types)
        end

      end

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

  end

end