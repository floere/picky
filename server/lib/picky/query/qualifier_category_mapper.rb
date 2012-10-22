module Picky

  # coding: utf-8
  #
  module Query

    # Collection class for qualifiers.
    #
    class QualifierCategoryMapper

      attr_reader :mapping
      
      #
      #
      def initialize indexes
        @mapping = {}
        indexes.each do |index|
          index.each_category do |category|
            add category
          end
        end
      end

      #
      #
      def add category
        category.qualifiers.each do |qualifier|
          sym_qualifier = qualifier.intern
          Picky.logger.warn %Q{Warning: Qualifier "#{qualifier}" already mapped to category #{mapping[sym_qualifier].identifier} (ambiguous qualifier mapping).} if mapping.has_key? sym_qualifier
          mapping[sym_qualifier] = category
        end
      end

      # Normalizes the given qualifier.
      #
      # Returns nil if it is not allowed, the normalized qualifier if it is.
      #
      def map qualifier
        return nil if qualifier.empty?

        @mapping[qualifier.intern]
      end
      
      # Restricts the given categories.
      #
      def restrict user_qualified
        if @restricted
          user_qualified ? @restricted & user_qualified : @restricted 
        else
          user_qualified
        end
      end
      def restrict_to *qualifiers
        @restricted = qualifiers.map { |qualifier| map qualifier }.compact
      end

    end

  end

end