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
        def encode str_or_sym
          str_or_sym.metaphone
        end

      end

    end

  end

end