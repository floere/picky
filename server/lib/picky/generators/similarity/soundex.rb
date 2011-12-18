module Picky

  # encoding: utf-8
  #
  module Generators

    module Similarity

      # It's actually a combination of soundex
      # and Levenshtein.
      #
      # It uses the soundex to get similar words
      # and ranks them using the levenshtein.
      #
      class Soundex < Phonetic

        # Encodes the given string/symbol.
        #
        # Returns a symbol.
        #
        def encode str_or_sym
          str_or_sym.soundex
        end

      end

    end

  end

end