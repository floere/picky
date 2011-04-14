# encoding: utf-8
#
# TODO Adapt the generated example
#      (a library books finder) to what you need.
#
# Questions? Mail me, IRC #picky, the google group, http://github.com/floere/picky/wiki.
#
class PickySearch < Application

  # How text is indexed. Move to Index block to make it index specific.
  #
  indexing removes_characters: /[^a-zA-Z0-9\s\/\-\"\&\.]/i,
           stopwords:          /\b(and|the|of|it|in|for)\b/i,
           splits_text_on:     /[\s\/\-\"\&\.]/

  # How query text is preprocessed. Move to Search block to make it search specific.
  #
  searching removes_characters: /[^a-zA-Z0-9\s\/\-\,\&\"\~\*\:]/i, # Picky needs control chars *"~: to pass through.
            stopwords:          /\b(and|the|of|it|in|for)\b/i,
            splits_text_on:     /[\s\/\-\,\&]+/,
            maximum_tokens: 5, # Amount of tokens used in a search (5 = default).
            substitutes_characters_with: CharacterSubstituters::WestEuropean.new # Normalizes special user input, Ä -> Ae, ñ -> n etc.

  books_index = Index::Memory.new :books do
    source   Sources::CSV.new(:title, :author, :year, file: 'app/library.csv')
    category :title,
             similarity: Similarity::DoubleMetaphone.new(3), # Default is no similarity.
             partial: Partial::Substring.new(from: 1) # Default is from: -3.
    category :author, partial: Partial::Substring.new(from: 1)
    category :year, partial: Partial::None.new
  end

  route %r{\A/books\Z} => Search.new(books_index) do
    boost [:title, :author] => +3, [:title] => +1
  end

end