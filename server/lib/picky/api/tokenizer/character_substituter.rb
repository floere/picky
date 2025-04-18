module Picky
  module API
    module Tokenizer
      module CharacterSubstituter
        def extract_character_substituter(thing)
          raise ArgumentError, <<~ERROR unless thing.respond_to? :substitute
            The substitutes_characters_with option needs a character substituter,
            which responds to #substitute(text) and returns substituted_text."
          ERROR

          thing
        end
      end
    end
  end
end
