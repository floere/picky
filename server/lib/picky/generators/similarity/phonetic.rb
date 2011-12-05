module Picky

  # encoding: utf-8
  #
  module Generators

    module Similarity

      # It's actually a combination of double metaphone
      # and Levenshtein.
      #
      # It uses the double metaphone to get similar words
      # and ranks them using the levenshtein.
      #
      class Phonetic < Strategy

        attr_reader :amount

        #
        #
        def initialize amount = 10
          raise "In Picky 2.0+, the Similarity::Phonetic has been renamed to Similarity::DoubleMetaphone. Please use that one. Thanks!" if self.class == Phonetic
          @amount = amount
        end

        # Sorts the index values in place.
        #
        def sort ary, code
            ary.sort_by_levenshtein! code
            ary.slice! amount, ary.size # THINK size is not perfectly correct, but anyway
        end

      end

    end

  end

end