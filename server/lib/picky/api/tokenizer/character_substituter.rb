module Picky
  module API
    module Tokenizer

      module CharacterSubstituter

        def extract_character_substituter thing
          if thing.respond_to? :substitute
            thing
          else
            raise ArgumentError.new <<-ERROR
The substitutes_characters_with option needs a character substituter,
which responds to #substitute(text) and returns substituted_text."
ERROR
          end
        end

      end

    end
  end
end