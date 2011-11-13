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
        def encoded str_or_sym
          code = Text::Soundex.soundex str_or_sym.to_s
          code.intern if code
        end

      end

    end

  end

end