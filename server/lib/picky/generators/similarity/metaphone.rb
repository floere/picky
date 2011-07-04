# encoding: utf-8
#
module Internals

  module Generators

    module Similarity

      # It's actually a combination of metaphone
      # and Levenshtein.
      #
      # It uses the metaphone to get similar words
      # and ranks them using the levenshtein.
      #
      class Metaphone < Phonetic

        # Encodes the given symbol.
        #
        # Returns a symbol.
        #
        def encoded sym
          code = Text::Metaphone.metaphone sym.to_s
          code.to_sym if code
        end

      end

    end

  end

end