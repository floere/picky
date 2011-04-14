module Internals

  module Indexed

    #
    #
    class Index

      attr_reader :name, :result_identifier, :combinator, :categories

      delegate :load_from_cache,
               :analyze,
               :to => :categories

      def initialize name, options = {}
        @name                     = name

        @result_identifier        = options[:result_identifier] || name
        @bundle_class             = options[:indexed_bundle_class] # TODO This should actually be a fixed parameter.
        ignore_unassigned_tokens  = options[:ignore_unassigned_tokens] || false # TODO Move to query, somehow.

        @categories = Categories.new ignore_unassigned_tokens: ignore_unassigned_tokens
      end

      def define_category category_name, options = {}
        options = default_category_options.merge options

        new_category = Category.new category_name, self, options
        categories << new_category
        new_category
      end

      # By default, the category uses
      # * the index's bundle type.
      #
      def default_category_options
        {
          :indexed_bundle_class => @bundle_class
        }
      end

      # Return the possible combinations for this token.
      #
      # A combination is a tuple <token, index_bundle>.
      #
      def possible_combinations token
        categories.possible_combinations_for token
      end

      def to_s
        <<-INDEX
Indexed(#{name}):
  Result identifier: "#{result_identifier}"
  Categories:
  #{categories.indented_to_s}
INDEX
      end

    end

  end

end