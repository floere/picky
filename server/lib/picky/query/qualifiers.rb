# coding: utf-8
#
module Internals

  #
  #
  module Query

    # A single qualifier.
    #
    class Qualifier # :nodoc:all

      attr_reader :normalized_qualifier, :codes

      #
      #
      # codes is an array.
      #
      def initialize normalized_qualifier, codes
        @normalized_qualifier = normalized_qualifier
        @codes                = codes.map &:to_sym
      end

      # Will overwrite if the key is present in the hash.
      #
      def inject_into hash
        codes.each do |code|
          hash[code] = normalized_qualifier
        end
      end

    end

    # Collection class for qualifiers.
    #
    class Qualifiers # :nodoc:all

      attr_reader :qualifiers, :normalization_mapping

      delegate :<<, :to => :qualifiers

      #
      #
      def initialize
        @qualifiers = []
        @normalization_mapping = {}
      end
      def self.instance
        @instanec ||= new
      end

      # TODO Spec.
      #
      def self.add name, qualifiers
        instance << Qualifier.new(name, qualifiers)
      end

      # Uses the qualifiers to prepare (optimize) the qualifier handling.
      #
      def prepare
        qualifiers.each do |qualifier|
          qualifier.inject_into normalization_mapping
        end
      end

      # Normalizes the given qualifier.
      #
      # Returns nil if it is not allowed, the normalized qualifier if it is.
      #
      # Note: Normalizes.
      #
      def normalize qualifier
        return nil if qualifier.blank?

        normalization_mapping[qualifier.to_sym]
      end

    end

  end

end