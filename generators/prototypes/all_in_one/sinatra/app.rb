require 'sinatra/base'
require 'i18n'
require 'haml'
require 'csv'
require 'picky'
require 'picky-client'

require File.expand_path '../book',    __FILE__
require File.expand_path '../logging', __FILE__

# This app shows how to integrate the Picky server directly
# inside a web app. However, if you really need performance
# and easy caching, this is not recommended.
#
class BookSearch < Sinatra::Application

  # We do this so we don't have to type
  # Picky:: in front of everything.
  #
  include Picky


  # Server.
  #

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
    source { Books.new }
    indexing removes_characters: /[^a-z0-9\s\/\-\_\:\"\&\.]/i,
             stopwords:          /\b(and|the|of|it|in|for)\b/i,
             splits_text_on:     /[\s\/\-\_\:\"\&\/]/
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
              removes_characters: /[^a-z0-9\s\/\-\_\&\.\"\~\*\:\,]/i, # Picky needs control chars *"~:, to pass through.
              stopwords:          /\b(and|the|of|it|in|for)\b/i,
              splits_text_on:     /[\s\/\-\&]+/

    boost [:title, :author] => +3,
          [:title]          => +1
  end


  # Client.
  #

  set :static, true
  set :public, File.dirname(__FILE__)
  set :views,  File.expand_path('../views', __FILE__)
  set :haml,   :format => :html5

  # Root, the search page.
  #
  get '/' do
    @query = params[:q]

    haml :'/search'
  end

  # Configure. The configuration info page.
  #
  get '/configure' do
    haml :'/configure'
  end

  # Renders the results into the json.
  #
  # You get the results from the (local) picky server and then
  # populate the result hash with rendered models.
  #
  get '/search/full' do
    results = books.search params[:query], params[:ids] || 20, params[:offset] || 0
    AppLogger.info results
    results = results.to_hash
    results.extend Picky::Convenience
    results.populate_with Book do |book|
      book.render
    end

    #
    # Or, to populate with the model instances, use:
    #   results.populate_with Book
    #
    # Then to render:
    #   rendered_entries = results.entries.map do |book| (render each book here) end
    #

    Yajl::Encoder.encode results
  end

  # Updates the search count while the user is typing.
  #
  get '/search/live' do
    results = books.search params[:query], params[:ids] || 20, params[:offset] || 0
    results.to_json
  end

  helpers do

    def js path
      "<script src='javascripts/#{path}.js' type='text/javascript'></script>"
    end

  end

end