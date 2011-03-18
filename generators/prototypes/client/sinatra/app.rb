require 'rubygems'
require 'bundler'
Bundler.require

# Load the "model".
#
require File.expand_path 'book', File.dirname(__FILE__)

# Sets up a search instance to the server.
#
BookSearch = Picky::Client.new :host => 'localhost', :port => 8080, :path => '/books'

set :static, true
set :public, File.dirname(__FILE__)
set :views,  File.expand_path('views', File.dirname(__FILE__))
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

# You get the ids from the picky server and then
# populate the result with rendered models.
#
get '/search/full' do
  results = BookSearch.search params[:query], :ids => params[:ids], :offset => params[:offset]
  results.extend Picky::Convenience
  results.populate_with Book do |book|
    book.to_s
  end

  #
  # Or use:
  #   results.populate_with Book
  #
  # Then:
  #   rendered_entries = results.entries.map do |book| (render each book here) end
  #

  ActiveSupport::JSON.encode results
end

# Normally, you'd actually go directly to the search server without taking the detour.
#
# We don't parse/reencode the returned json string using search_unparsed.
#
get '/search/live' do
  BookSearch.search_unparsed params[:query], :ids => params[:ids], :offset => params[:offset]
end

helpers do

  def js path
    "<script src='javascripts/#{path}.js' type='text/javascript'></script>"
  end

end