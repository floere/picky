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
        def initialize amount = 3
          check_gem
          @amount = amount
        end

        # Tries to require the text gem.
        #
        def check_gem
          require 'text'
        rescue LoadError
          warn_gem_missing 'text', 'a phonetic Similarity'
          exit 1
        end

        # Sorts the index values in place.
        #
        def prioritize ary, code
          ary.sort_by_levenshtein! code
          ary.slice! amount, ary.size # Note: The ary.size is not perfectly correct.
        end

      end

    end

  end

end