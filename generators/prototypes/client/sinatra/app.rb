require 'rubygems'
require 'bundler'
Bundler.require

# Sinatra settings.
#
set :static, true
set :public, File.dirname(__FILE__)
set :views,  File.expand_path('../views', __FILE__)
set :haml,   :format => :html5

# Load the simplified "model".
#
require File.expand_path '../book', __FILE__

# Sets up a search instance to the server.
#
BookSearch = Picky::Client.new :host => 'localhost', :port => 8080, :path => '/books'

# Root, the search page.
#
get '/' do
  @query = params[:q]

  haml :'/search'
end

# Renders the results into the json.
#
# You get the ids from the picky server and then
# populate the result with rendered models.
#
get '/search/full' do
  results = BookSearch.search params[:query], :ids => params[:ids], :offset => params[:offset]
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

  ActiveSupport::JSON.encode results
end

# Updates the search count while the user is typing.
#
# We don't parse/reencode the returned json string using search_unparsed.
#
get '/search/live' do
  BookSearch.search_unparsed params[:query], :ids => params[:ids], :offset => params[:offset]
end

# Configure. The configuration info page.
#
get '/configure' do
  haml :'/configure'
end

helpers do

  def js path
    "<script src='javascripts/#{path}.js' type='text/javascript'></script>"
  end

end