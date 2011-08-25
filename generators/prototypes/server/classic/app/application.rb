# encoding: utf-8
#
require File.expand_path '../logging', __FILE__

# TODO Adapt the generated example
#      (a library books finder) to what you need.
#
# Questions? Mail me, IRC #picky, the google group, http://github.com/floere/picky/wiki.
#
class BookSearch < Picky::Application

  # So we don't have to write Picky::
  # in front of everything.
  #
  include Picky

  # How text is indexed. Move to Index block to make it index specific.
  #
  indexing removes_characters: /[^a-zA-Z0-9\s\/\-\_\:\"\&\.]/i,
           stopwords:          /\b(and|the|of|it|in|for)\b/i,
           splits_text_on:     /[\s\/\-\_\:\"\&\/]/

  # How query text is preprocessed. Move to Search block to make it search specific.
  #
  searching substitutes_characters_with: CharacterSubstituters::WestEuropean.new, # Normalizes special user input, Ä -> Ae, ñ -> n etc.
            removes_characters: /[^a-zA-Z0-9\s\/\-\_\&\.\"\~\*\:\,]/i, # Picky needs control chars *"~:, to pass through.
            stopwords:          /\b(and|the|of|it|in|for)\b/i,
            splits_text_on:     /[\s\/\-\&]+/,
            maximum_tokens: 5   # Amount of tokens maximally used in a search.

  books_index = Index.new :books do
    source   Sources::CSV.new(:title, :author, :year, file: "data/#{PICKY_ENVIRONMENT}/library.csv")
    category :title,
             similarity: Similarity::DoubleMetaphone.new(3), # Default is no similarity.
             partial: Partial::Substring.new(from: 1) # Default is from: -3.
    category :author, partial: Partial::Substring.new(from: 1)
    category :year, partial: Partial::None.new
  end

  books = Search.new books_index do
    boost [:title, :author] => +3,
          [:title] => +1
  end

  route %r{\A/books\Z} => books

end