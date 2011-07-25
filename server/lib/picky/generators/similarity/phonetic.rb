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

        # Generates an index for the given index (in exact index style).
        #
        # In the following form:
        # [:meier, :mueller, :peter, :pater] => { MR: [:meier], MLR: [:mueller], PTR: [:peter, :pater] }
        #
        def generate_from inverted
          hash = hashify inverted.keys
          sort hash
        end

        protected

          # Sorts the index values in place.
          #
          def sort hash
            hash.each_pair.each do |code, ary|
              ary.sort_by_levenshtein! code
              ary.slice! amount, ary.size # size is not perfectly correct, but anyway
            end
            hash
          end

          # Hashifies a list of symbols.
          #
          # Where:
          # { encoded_sym => [syms] }
          #
          def hashify list
            list.inject({}) do |total, element|
              if code = encoded(element)
                total[code] ||= []
                total[code] << element
              end
              total
            end
          end

      end

    end

  end

end