# encoding: utf-8
#
module Picky

  class Results

    # This index combines an exact and partial index.
    # It serves to order the results such that exact hits are found first.
    #
    module ExactFirst

      # Installs the exact first on the given category
      # or on the categories of the index, if an index is given.
      #
      # THINK Can we unextend in the case it is an index?
      #
      def self.extended index_or_category
        if index_or_category.respond_to? :categories
          extend_each_of index_or_category.categories
          index_or_category
        end
      end
      def self.extend_each_of categories
        categories.categories.each { |category| category.extend self }
      end

      # Overrides the original method.
      #
      def ids token
        text = token.text
        if token.partial?
          exact.ids(text) | partial.ids(text)
        else
          exact.ids text
        end
      end

      # Overrides the original method.
      #
      def weight token
        text = token.text
        if token.partial?
          [exact.weight(text), partial.weight(text)].compact.max
        else
          exact.weight text
        end
      end

    end

  end

end