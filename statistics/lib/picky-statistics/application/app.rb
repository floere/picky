# This is a sinatra app packaged in a gem, running directly from the gem.
#
raise "ENV['PICKY_LOG_FILE'] needs to be set for the statistics app to be run. Use either it, or run 'picky stats <logfile> <port>'." unless ENV['PICKY_LOG_FILE']

log_file = File.expand_path ENV['PICKY_LOG_FILE'], Dir.pwd
port     = ENV['PICKY_STATISTICS_PORT'] || 4567

Dir.chdir File.expand_path('..', __FILE__)

require 'sinatra'
require 'haml'

begin
  require File.expand_path '../../picky-statistics', Dir.pwd
rescue LoadError => e
  require 'picky-statistics'
end

Stats = LogfileReader.new log_file

class PickyStatistics < Sinatra::Base
  
  set :static, true
  set :public_folder, File.expand_path('.', Dir.pwd)
  set :views,  File.expand_path('views', Dir.pwd)
  set :haml, { :format => :html5 }
  
  # Returns an index page with all the statistics.
  #
  get '/' do
    haml :'/index'
  end

  # Returns statistics data in JSON for the index page.
  #
  get '/index.json' do
    Stats.since(0).to_json
  end
  
  # Returns statistics data in JSON since the last request.
  #
  get '/since_last.json' do
    Stats.since_last.to_json
  end
  
end

puts "Clam, Picky's friend, is looking at Picky's logfile\n#{log_file}\nand showing results on port #{port}."
PickyStatistics.run! :port => port