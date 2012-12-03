# encoding: utf-8
#
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

  # Server.
  #

  require_relative 'books_index'
  require_relative 'books_search'

  # Client.
  #

  set :static,        true
  set :public_folder, File.dirname(__FILE__)
  set :views,         File.expand_path('../views', __FILE__)
  set :haml,          :format => :html5

  # Root, the search page.
  #
  get '/' do
    @query = params[:q]

    haml :'/search'
  end

  # Renders the results into the json.
  #
  # You get the results from the (local) picky server and then
  # populate the result hash with rendered models.
  #
  get '/search/full' do
    results = BooksSearch.search params[:query], params[:ids] || 20, params[:offset] || 0
    Picky.logger.info results
    results = results.to_hash
    results.extend Picky::Convenience
    results.populate_with Book do |book|
      book.to_s
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
    results = BooksSearch.search params[:query], params[:ids] || 20, params[:offset] || 0
    results.to_json
  end

  helpers do

    def js path
      "<script src='javascripts/#{path}.js' type='text/javascript'></script>"
    end

  end

end
