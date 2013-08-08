module Picky

  module Query

    # Calculates boosts for combinations.
    #
    # Example:
    #   Someone searches for peter fish.
    #   Picky might match this to categories as follows:
    #     [:name, :food]
    #   and
    #     [:name, :surname]
    #
    # This class is concerned with calculating boosts
    # for the category combinations.
    #
    # Implement either
    #   #boost_for(combinations)
    # or
    #   #boost_for_categories(category_names) # Subclass this class for this.
    #
    # And return a boost (float).
    #
    class Boosts

      attr_reader :boosts

      forward :empty?, :to => :boosts

      # Needs a Hash of
      #   [:category_name1, :category_name2] => +3
      # (some positive or negative weight)
      #
      def initialize boosts = {}
        @boosts = boosts
      end

      # API.
      #
      # Get the boost for an array of category names.
      #
      # Example:
      #   [:name, :height, :color] returns +3, but
      #   [:name, :height, :street] returns -1.
      #
      # Note: Use Array#clustered_uniq to make
      #       [:a, :a, :b, :a] => [:a, :b, :a]
      #
      def boost_for_categories names
        @boosts[names.clustered_uniq] || 0
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
      # TODO Push into categories? Store boosts in categories?
      #
      def boost_for combinations
        boost_for_categories combinations.map { |combination| combination.category_name }
      end

      # A Weights instance is == to another if
      # the weights are the same.
      #
      def == other
        @boosts == other.boosts
      end

      # Prints out a nice representation of the
      # configured weights.
      #
      def to_s
        "#{self.class}(#@boosts)"
      end

    end
  end

end