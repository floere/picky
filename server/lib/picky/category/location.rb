module Picky
  class Category

    module Location

      def self.install_on category, grid, precision, anchor
        category.extend self

        exact_bundle = category.exact
        category.exact   = Wrappers::Bundle::Location.new(exact_bundle, grid, precision: precision, anchor: anchor)
        category.partial = Wrappers::Bundle::Location.new(exact_bundle, grid, precision: precision, anchor: anchor)

        category
      end

      # Only uses a basic tokenizer that's already geared towards numbers.
      #
      def tokenizer
        @tokenizer ||= Tokenizer.new
      end

    end

  end
end