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

      delegate :empty?,
               :inject,
               :to => :@combinations

      def initialize combinations = []
        @combinations = combinations
      end

      def hash
        @combinations.hash
      end

      def score
        @combinations.sum &:weight
      end
      def boost_for weights
        weights.boost_for @combinations
      end

      # Filters the tokens and categories such that categories
      # that are passed in, are removed.
      #
      # Note: This method is not totally independent of the calculate_ids one.
      # Since identifiers are only nullified, we need to not include the
      # ids that have an associated identifier that is nil.
      #
      def remove categories = []
        @combinations.reject! { |combination| categories.include?(combination.category) }
      end

      #
      #
      def to_result
        @combinations.map &:to_result
      end

      #
      #
      def to_s
        @combinations.to_s
      end

    end

  end

end