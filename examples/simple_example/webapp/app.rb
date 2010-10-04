require 'rubygems'
require 'bundler'
Bundler.require

require File.expand_path 'book', File.dirname(__FILE__)
require File.expand_path 'helper', File.dirname(__FILE__)

# What you would do in an app.
#
FullBooks = Picky::Client::Full.new :host => 'picky-simple-example-backend.heroku.com', :port => 80, :path => '/books/full'
LiveBooks = Picky::Client::Live.new :host => 'picky-simple-example-backend.heroku.com', :port => 80, :path => '/books/live'

set :static, true
set :public, File.dirname(__FILE__)

# Search Interface.
#
get '/' do
  wrap_in_html Picky::Helper.interface
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