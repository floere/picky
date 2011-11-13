module Picky

  # encoding: utf-8
  #
  module Generators

    module Similarity

      # It's actually a combination of metaphone
      # and Levenshtein.
      #
      # It uses the metaphone to get similar words
      # and ranks them using the levenshtein.
      #
      class Metaphone < Phonetic

        # Encodes the given string/symbol.
        #
        # Returns a symbol.
        #
        def encoded str_or_sym
          code = Text::Metaphone.metaphone str_or_sym.to_s
          code.intern if code
        end

      end

    end

  end

end