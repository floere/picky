require 'sinatra'

require 'picky-statistics'

# Returns an index page with all the statistics.
#
get '/' do
  
end

# Returns statistics data in JSON for the index page.
#
get '/index.json' do
  Statistics.from params[:from] || Time.parse('1900,1,1')
end