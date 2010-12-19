# This is a sinatra app packaged in a gem, running directly from the gem.
#
STATISTICS_DIR = Dir.pwd

require 'sinatra'
require 'haml'
require 'json'

set :static, true
set :public, File.dirname(__FILE__)
set :views,  File.expand_path('../views', __FILE__)
set :haml, { :format => :html5 }

begin
  require File.expand_path '../../../picky-statistics', __FILE__
rescue LoadError => e
  require 'picky-statistics'
end

Stats = Statistics::LogfileReader.new 'spec/data/search.log'

# Returns an index page with all the statistics.
#
get '/' do
  haml :'/index'
end

# Returns statistics data in JSON for the index page.
#
get '/index.json' do
  stats = Stats.since_last
  stats.to_json
end