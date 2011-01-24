# This is a sinatra app packaged in a gem, running directly from the gem.
#

live_url = ENV['PICKY_LIVE_URL']  || 'localhost:8080/admin'
port     = ENV['PICKY_LIVE_PORT'] || 4568

Dir.chdir File.expand_path('..', __FILE__)

require 'sinatra'
require 'haml'
require 'net/http'

begin
  require File.expand_path '../../../picky-live', __FILE__
rescue LoadError => e
  require 'picky-live'
end

uri = URI.parse live_url
Server = Backend.new :host => uri.host, :port => uri.port, :path => uri.path

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
    Server.get
  end
  
end

puts "Suckerfish, Picky's friend, has sucked onto Picky at #{live_url}."
PickyLive.run! :port => port