module Picky

  module Query

    # Calculates scores/weights for combinations.
    #
    # Example:
    #   Someone searches for peter fish.
    #   Picky might match this to categories as follows:
    #     [:name, :food]
    #   and
    #     [:name, :surname]
    #
    # This class is concerned with calculating scores
    # for the category combinations.
    #
    # Implement either
    #   #score_for(combinations)
    # or
    #   #weight_for(category_names) # Subclass this class for this.
    #
    # And return a weight.
    #
    class Weights

      attr_reader :weights

      delegate :empty?,
               :to => :weights

      # Needs a Hash of
      #   [:category_name1, :category_name2] => +3
      # (some positive or negative weight)
      #
      def initialize weights = {}
        @weights = weights
      end

      # API.
      #
      # Get the weight for an array of category names.
      #
      # Example:
      #   [:name, :height, :color] returns +3, but
      #   [:name, :height, :street] returns -1.
      #
      # Note: Use Array#clustered_uniq_fast to make
      #       [:a, :a, :b, :a] => [:a, :b, :a]
      #
      def weight_for category_names
        @weights[category_names.clustered_uniq_fast] || 0
      end

      # API.
      #
      # Calculates a score for the combinations.
      # Implement #weight_for(category_names) if you don't need the
      # actual combinations, just the category names.
      #
      # Note: Cache this if more complicated weighings become necessary.
      # Note: Maybe make combinations comparable to Symbols?
      #
      def score_for combinations
        weight_for combinations.map(&:category_name)
      end

      # A Weights instance is == to another if
      # the weights are the same.
      #
      def == other
        @weights == other.weights
      end

      # Prints out a nice representation of the
      # configured weights.
      #
      def to_s
        "#{self.class}(#{@weights})"
      end

    end
  end

end