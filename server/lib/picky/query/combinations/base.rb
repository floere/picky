module Picky

  module Query

    # Combinations are a number of Combination-s.
    #
    # They are the core of an allocation.
    # An allocation consists of a number of combinations.
    #
    module Combinations # :nodoc:all

      # Base Combinations contain methods for calculating score and ids.
      #
      class Base

        attr_reader :combinations

        delegate :empty?, :to => :@combinations

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
          weights.score @combinations
        end

        # Filters the tokens and identifiers such that only identifiers
        # that are passed in, remain, including their tokens.
        #
        # Note: This method is not totally independent of the calculate_ids one.
        #       Since identifiers are only nullified, we need to not include the
        #       ids that have an associated identifier that is nil.
        #
        def keep identifiers = []
          @combinations.reject! { |combination| !combination.in?(identifiers) }
        end

        # Filters the tokens and identifiers such that identifiers
        # that are passed in, are removed, including their tokens.
        #
        # Note: This method is not totally independent of the calculate_ids one.
        #       Since identifiers are only nullified, we need to not include the
        #       ids that have an associated identifier that is nil.
        #
        def remove identifiers = []
          @combinations.reject! { |combination| combination.in?(identifiers) }
        end

        #
        #
        def to_result
          @combinations.map &:to_result
        end

      end

    end

  end

end