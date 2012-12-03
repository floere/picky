# encoding: utf-8
#
require 'sinatra/base'
require 'csv'
require 'picky'
require File.expand_path '../logging', __FILE__

class BookSearch < Sinatra::Application

  require_relative 'books_index'
  require_relative 'books_search'

  # Route /books to the books search and log when searching.
  #
  get '/books' do
    results = BooksSearch.search params[:query], params[:ids] || 20, params[:offset] || 0
    Picky.logger.info results
    results.to_json
  end

end
