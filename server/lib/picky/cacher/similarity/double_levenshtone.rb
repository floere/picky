# encoding: utf-8
#
module Cacher

  module Similarity

    # DoubleLevensthone means that it's a combination of
    # * DoubleMetaphone
    # and
    # * Levenshtein
    # :)
    #
    class DoubleLevenshtone < Strategy

      attr_reader :amount

      #
      #
      def initialize amount = 10
        @amount = amount
      end

      # Encodes the given symbol.
      #
      # Returns a symbol.
      #
      def encoded sym
        codes = Text::Metaphone.double_metaphone sym.to_s
        codes.first.to_sym unless codes.empty?
      end

      # Generates an index for the given index (in exact index style).
      #
      # In the following form:
      # [:meier, :mueller, :peter, :pater] => { :MR => [:meier], :MLR => [:mueller], :PTR => [:peter, :pater] }
      #
      def generate_from index
        hash = hashify index.keys
        sort hash
      end

      private

        # Sorts the index values in place.
        #
        def sort index
          index.each_pair.each do |code, ary|
            ary.sort_by_levenshtein! code
            ary.slice! amount, ary.size # size is not perfectly correct, but anyway
          end
          index
        end

        # Hashifies a list of symbols.
        #
        # Where:
        # { encoded_sym => [syms] }
        #
        def hashify list
          list.inject({}) do |total, element|
            if code = encoded(element)
              total[code] ||= []
              total[code] << element
            end
            total
          end
        end

    end

  end

end