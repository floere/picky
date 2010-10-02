require 'rubygems'
require 'bundler'
Bundler.require

require File.expand_path 'helper', File.dirname(__FILE__)

# What you would do in an app.
#
# PickyBackend = Picky::Client::Full.new :host => 'localhost', :port => 4000, :path => '/books/full'

set :static, true
set :public, File.dirname(__FILE__)

# Search Interface.
#
get '/' do
  wrap_in_html Picky::Helper.interface
end

# Normally, you'd access the picky server directly for the live data.
#
get '/search/live' do
  # Return a fake result
  results = {
    :allocations => [
      ["book",25.22,203,[["title","Old","old"],["title","Man","man"]],[]],
      ["book",22.16,56,[["author","Old","old"],["title","Man","man"]],[]]
    ],
    :offset => 0,
    :total => rand(2000),
    :duration => rand(1)
  }
  ActiveSupport::JSON.encode results
end

# For full results, you get the ids from the picky server
# and then populate the result with models (rendered, even).
#
get '/search/full' do
  # What you would do:
  #
  # result = PickyBackend.search :query => params[:query], :offset => params[:offset]
  # result.extend Picky::Convenience
  # result.populate_with(SomeModelClass) { |model| render model }
  # result.to_json
  #
  
  # Return a fake result
  results = {
    :allocations => [
      ["book",25.22,2,[["title","Old","old"],["title","Man","man"]],[],['<div class="item">Content Result a1</div>','<div class="item">Content Result a2</div>']],
      ["book",22.16,1,[["author","Old","old"],["title","Man","man"]],[],['<div class="item">Content Result b1</div>']],
      ["book",13.11,1,[["author","Old","old"],["author","Man","man"]],[],['<div class="item">Content Result c1</div>']],
      ["book",5.23,1,[["author","Man","man"],["author","Old","old"]],[],['<div class="item">Content Result d1</div>']],
    ].sort_by { rand },
    :offset => 0,
    :total => rand(20),
    :duration => rand(1)
  }
  ActiveSupport::JSON.encode results
end