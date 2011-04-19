require 'rubygems'
require 'bundler'
Bundler.require

# Load the "model".
#
require File.expand_path 'location', File.dirname(__FILE__)

set :haml, { :format => :html5 }

# Sets up two query instances.
#
Geo = Picky::Client.new :host => 'localhost', :port => 8080, :path => '/geo'

set :static, true
set :public, File.dirname(__FILE__)
set :views,  File.expand_path('views', File.dirname(__FILE__))

# Root, the search interface.
#
get '/' do
  haml :'/search'
end

# Configure. The configuration info page.
#
get '/configure' do
  haml :'/configure'
end

# For full results, you get the ids from the picky server
# and then populate the result with models (rendered, even).
#
get '/search/full' do
  results = Geo.search params[:query], :ids => params[:ids], :offset => params[:offset]
  results.extend Picky::Convenience
  results[:geo] ||= []
  results.populate_with Location do |location|
    results[:geo] << [location.north, location.east]
    location.to_s
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

# For live results, you'd actually go directly to the search server without taking the detour.
#
get '/search/live' do
  Geo.search_unparsed params[:query], :ids => 0, :offset => params[:offset]
end

helpers do

  def js path
    "<script src='javascripts/#{path}.js' type='text/javascript'></script>"
  end

end