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
      class DoubleMetaphone < Phonetic

        # Encodes the given string/symbol.
        #
        # Returns a symbol.
        #
        def encode str_or_sym
          str_or_sym.double_metaphone
        end

      end

    end

  end

end