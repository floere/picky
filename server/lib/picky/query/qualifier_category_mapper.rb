module Picky

  # coding: utf-8
  #
  module Query

    # Collection class for qualifiers.
    #
    class QualifierCategoryMapper # :nodoc:all

      attr_reader :mapping

      #
      #
      def initialize
        @mapping = {}
      end

      #
      #
      def add category
        category.qualifiers.each do |qualifier|
          sym_qualifier = qualifier.to_sym
          warn %Q{Warning: Qualifier "#{qualifier}" already mapped to category #{mapping[sym_qualifier].identifier} (ambiguous qualifier mapping).} if mapping.has_key? sym_qualifier
          mapping[sym_qualifier] = category
        end
      end

      # Normalizes the given qualifier.
      #
      # Returns nil if it is not allowed, the normalized qualifier if it is.
      #
      def map qualifier
        return nil if qualifier.blank?

        @mapping[qualifier.to_sym]
      end

    end

  end

end