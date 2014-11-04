module Picky

  module Query

    # Combinations represent an ordered list of Combination s.
    #
    # Combinations contain methods for calculating score (including
    # the boost) and ids for each of its Combination s.
    #
    # They are the core of an Allocation.
    # An Allocation consists of a number of Combinations.
    #
    class Combinations

      attr_reader :combinations

      forward :empty?,
              :inject,
              :map,
              :to => :@combinations

      def initialize combinations = []
        @combinations = combinations
      end

      # TODO
      #
      def each &block
        @combinations.each &block
      end

      # Sums up the weights of the combinations.
      #
      # Note: Optimized sum(&:weight) away – ~3% improvement.
      #
      def score
        @combinations.inject(0) { |total, combination| total + combination.weight }
      end

      # Filters the tokens and categories such that categories
      # that are passed in, are removed.
      #
      # Note: This method is not totally independent of the calculate_ids one.
      # Since identifiers are only nullified, we need to not include the
      # ids that have an associated identifier that is nil.
      #
      def remove categories = []
        # TODO Do not use the name, but the category.
        #
        @combinations.reject! { |combination| categories.include?(combination.category_name) }
      end

      #
      #
      def to_result
        @combinations.map &:to_result
      end

      def to_qualifiers
        @combinations.map &:category_name
      end

      #
      #
      def to_s
        @combinations.to_s
      end

    end

  end

end