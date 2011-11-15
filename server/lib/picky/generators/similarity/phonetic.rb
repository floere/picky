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

        protected

          # Sorts the index values in place.
          #
          # TODO Include this again. Sort at the end.
          #      Or sort when inserting in realtime.
          #
          def sort hash
            hash.each_pair.each do |code, ary|
              ary.sort_by_levenshtein! code
              ary.slice! amount, ary.size # size is not perfectly correct, but anyway
            end
            hash
          end

      end

    end

  end

end