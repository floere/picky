module Picky

  module Query

    # Describes the #Combination of a #Token (the text) and
    # the index (the bundle): [text, index_bundle]
    #
    # A #Combination is a single part of an allocation:
    # [..., [text2, index_bundle2], ...]
    #
    # An #Allocation consists of an ordered number of #Combinations:
    # [[text1, index_bundle1], [text2, index_bundle2], [text3, index_bundle1]]
    #
    class Combination

      attr_reader :token,
                  :category

      def initialize token, category
        @token    = token
        @category = category
      end

      # Returns the category's name.
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
      # Note: Caching is most of the time useful.
      #
      def weight
        @weight ||= category.weight(token)
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

      # Note: Required for uniq!
      #
      # THINK Ok with category or is the bundle needed?
      #
      def hash
        [token, category].hash
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
      #  "exact title:Peter*:peter"
      #
      def to_s
        "#{category.bundle_for(token).identifier}(#{to_result.join(':')})"
      end

    end

  end

end