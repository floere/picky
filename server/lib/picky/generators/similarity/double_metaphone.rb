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
        def encoded str_or_sym
          codes = Text::Metaphone.double_metaphone str_or_sym.to_s
          codes.first.intern unless codes.empty?
        end

      end

    end

  end

end