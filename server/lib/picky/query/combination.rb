module Picky

  module Query

    # Describes the Combination of:
    #  * a token
    #  * a category
    #  * the weight of the token in the category (cached from earlier)
    #
    # An Allocation consists of an ordered number of Combinations.
    #
    class Combination

      attr_reader :token,
                  :category,
                  :weight

      def initialize token, category, weight
        @token    = token
        @category = category
        @weight   = weight
      end

      # Returns the category's name.
      # Used in boosting.
      #
      def category_name
        @category_name ||= category.name
      end

      #
      #
      def bundle
        category.bundle_for token
      end

      # Returns the weight of this combination.
      #
      def weight
        @weight
      end

      # Returns an array of ids for the given text.
      #
      # Note: Caching is most of the time useful.
      #
      def ids
        @ids ||= category.ids(token)
      end

      # The identifier for this combination.
      #
      def identifier
        @identifier ||= "#{bundle.identifier}:inverted:#{token.text}"
      end

      # Combines the category names with the original names.
      # [
      #  [:title,    'Flarbl', :flarbl],
      #  [:category, 'Gnorf',  :gnorf]
      # ]
      #
      def to_result
        [category_name, *token.to_result]
      end

      # Example:
      #   "exact title:Peter*:peter"
      #
      def to_s
        "(#{category.bundle_for(token).identifier},#{to_result.join(':')})"
      end

    end

  end

end