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

        # Encodes the given symbol.
        #
        # Returns a symbol.
        #
        def encoded sym
          codes = Text::Metaphone.double_metaphone sym.to_s
          codes.first.to_sym unless codes.empty?
        end

      end

    end

  end

end