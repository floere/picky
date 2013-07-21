# encoding: utf-8
#

# Define a search over the books index.
#
BooksSearch = Picky::Search.new BooksIndex do
            # Normalizes special user input, Ä -> Ae, ñ -> n etc.
  searching substitutes_characters_with: Picky::CharacterSubstituters::WestEuropean.new,
            # Picky needs control chars *"~:, to pass through.
            removes_characters: /[^\p{L}\p{N}\s\/\-\_\&\.\"\~\*\:\,|]/i,
            stopwords:          /\b(and|the|of|it|in|for)\b/i,
            splits_text_on:     /[\s\/\-\&]+/

  boost [:title, :author] => +3,
        [:title]          => +1
end