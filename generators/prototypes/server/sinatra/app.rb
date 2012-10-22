# encoding: utf-8
#
require 'sinatra/base'
require 'csv'
require 'picky'
require File.expand_path '../logging', __FILE__

class BookSearch < Sinatra::Application

  # We do this so we don't have to type
  # Picky:: in front of everything.
  #
  include Picky

  # Data source.
  #
  class Books

    def initialize
      @csv = CSV.new File.open(File.expand_path("../data/#{PICKY_ENVIRONMENT}/library.csv", __FILE__))
    end

    def each
      instance = Struct.new :id, :title, :author, :year
      @csv.each do |row|
        yield instance.new *row[0..3]
      end
    end

  end

  # Define an index.
  #
  books_index = Index.new :books do
    source   { Books.new }
    indexing removes_characters: /[^a-z0-9\s\/\-\_\:\"\&\.]/i,
             stopwords:          /\b(and|the|of|it|in|for)\b/i,
             splits_text_on:     /[\s\/\-\_\:\"\&\.]/
    category :title,
             similarity: Similarity::DoubleMetaphone.new(3),
             partial: Partial::Substring.new(from: 1) # Default is from: -3.
    category :author, partial: Partial::Substring.new(from: 1)
    category :year, partial: Partial::None.new
  end

  # Index and load on USR1 signal.
  #
  Signal.trap('USR1') do
    books_index.reindex # kill -USR1 <pid>
  end

  # Define a search over the books index.
  #
  books = Search.new books_index do
    searching substitutes_characters_with: CharacterSubstituters::WestEuropean.new, # Normalizes special user input, Ä -> Ae, ñ -> n etc.
              removes_characters: /[^\p{L}\p{N}\s\/\-\_\&\.\"\~\*\:\,]/i, # Picky needs control chars *"~:, to pass through.
              stopwords:          /\b(and|the|of|it|in|for)\b/i,
              splits_text_on:     /[\s\/\-\&]+/
    boost [:title, :author] => +3,
          [:title]          => +1
  end

  # Route /books to the books search and log when searching.
  #
  get '/books' do
    results = books.search params[:query], params[:ids] || 20, params[:offset] || 0
    Picky.logger.info results
    results.to_json
  end

end
