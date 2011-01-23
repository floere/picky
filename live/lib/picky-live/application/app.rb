# This is a sinatra app packaged in a gem, running directly from the gem.
#
raise "ENV['PICKY_LIVE_URL'] needs to be set for the live app to be run. Use either it, or run 'picky live <url>'. Default for <url> is localhost:8080/admin." unless ENV['PICKY_LIVE_URL']

live_url = ENV['PICKY_LIVE_URL']

Dir.chdir File.expand_path('..', __FILE__)

require 'sinatra'
require 'haml'

begin
  require File.expand_path '../../../picky-live', __FILE__
rescue LoadError => e
  require 'picky-live'
end

Stats = Statistics::LogfileReader.new log_file

class PickyLive < Sinatra::Base
  
  set :static, true
  set :public, File.expand_path('..', __FILE__)
  set :views,  File.expand_path('../views', __FILE__)
  set :haml, { :format => :html5 }
  
  # Returns an index page with all the statistics.
  #
  get '/' do
    haml :'/index'
  end

  # Returns statistics data in JSON for the index page.
  #
  get '/index.json' do
    Backend.get
  end
  
end

puts "Suckerfish, Picky's friend, has sucked onto Picky at #{live_url}."
PickyLive.run! :port => port