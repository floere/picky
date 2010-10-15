require 'rubygems'
require 'bundler'
Bundler.require

require File.expand_path 'book', File.dirname(__FILE__)

set :haml, { :format => :html5 } # default Haml format is :xhtml

# What you would do in an app.
#
FullBooks = Picky::Client::Full.new :host => 'picky-simple-example-backend.heroku.com', :port => 80, :path => '/books/full'
LiveBooks = Picky::Client::Live.new :host => 'picky-simple-example-backend.heroku.com', :port => 80, :path => '/books/live'

set :static, true
set :public, File.dirname(__FILE__)
set :views,  File.expand_path('views', File.dirname(__FILE__))

# Search Interface.
#
get '/' do
  haml :'/search'
end

# For full results, you get the ids from the picky server
# and then populate the result with models (rendered, even).
#
get '/search/full' do
  results = FullBooks.search :query => params[:query], :offset => params[:offset]
  results.extend Picky::Convenience
  results.populate_with Book do |book|
    book.to_s
  end
  
  ActiveSupport::JSON.encode results
end

# For live results, you'd actually go directly to the search server.
#
get '/search/live' do
  LiveBooks.search :query => params[:query], :offset => params[:offset]
end

helpers do
  
  def js path
    "<script src='javascripts/#{path}.js' type='text/javascript'></script>"
  end
  
end