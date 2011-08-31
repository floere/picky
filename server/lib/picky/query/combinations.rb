module Picky

  module Query

    # Combinations are a number of Combination-s.
    #
    # They are the core of an allocation.
    # An allocation consists of a number of combinations.
    #
    # Base Combinations contain methods for calculating score and ids.
    #
    class Combinations # :nodoc:all

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

      # Uses user specific weights to calculate a score for the combinations.
      #
      def calculate_score weights
        total_score + weighted_score(weights)
      end
      def total_score
        @combinations.sum &:weight
      end
      def weighted_score weights
        weights.score_for @combinations
      end

      # Filters the tokens and categories such that categories
      # that are passed in, are removed.
      #
      # Note: This method is not totally independent of the calculate_ids one.
      #       Since identifiers are only nullified, we need to not include the
      #       ids that have an associated identifier that is nil.
      #
      def remove categories = []
        @combinations.reject! { |combination| categories.include?(combination.category) }
      end

      #
      #
      def to_result
        @combinations.map &:to_result
      end

    end

  end

end