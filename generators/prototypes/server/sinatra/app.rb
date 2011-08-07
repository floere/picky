require 'sinatra/base'
require 'picky'

class BookSearch < Sinatra::Application

  # We do this so we don't have to type
  # Picky:: in front of everything.
  #
  include Picky

  # Define an index.
  #
  books_index = Indexes::Memory.new :books do
    source   Sources::CSV.new(:title, :author, :year, file: "data/#{PICKY_ENVIRONMENT}/library.csv")
    indexing removes_characters: /[^a-zA-Z0-9\s\/\-\_\:\"\&\.]/i,
             stopwords:          /\b(and|the|of|it|in|for)\b/i,
             splits_text_on:     /[\s\/\-\_\:\"\&\/]/
    category :title,
             similarity: Similarity::DoubleMetaphone.new(3),
             partial: Partial::Substring.new(from: 1) # Default is from: -3.
    category :author, partial: Partial::Substring.new(from: 1)
    category :year, partial: Partial::None.new
  end

  # Index and load on startup.
  #
  unless PICKY_ENVIRONMENT == 'test'
    books_index.index
    books_index.reload
  end

  # Index and load on USR1 signal.
  #
  Signal.trap('USR1') do
    books_index.reindex # kill -USR1 <pid>
  end

  # Define a search over the books index.
  #
  search = Search.new(books_index) do
    searching removes_characters: /[^a-zA-Z0-9\s\/\-\_\&\.\"\~\*\:\,]/i, # Picky needs control chars *"~:, to pass through.
              stopwords:          /\b(and|the|of|it|in|for)\b/i,
              splits_text_on:     /[\s\/\-\&]+/,
              substitutes_characters_with: CharacterSubstituters::WestEuropean.new # Normalizes special user input, Ä -> Ae, ñ -> n etc.
    boost [:title, :author] => +3, [:title] => +1
  end

  # Route /books to the books search.
  #
  get '/books' do
    results = search.search_with_text params[:query], params[:ids] || 20, params[:offset] || 0
    results.to_json
  end

end