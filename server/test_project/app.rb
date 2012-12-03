# encoding: utf-8
#

# 1. Index using rake index
# 2. Start with rake start
# 3. curl '127.0.0.1:8080/all?query=bla'
#

# Stresstest using
#   ab -kc 5 -t 5 http://127.0.0.1:4567/csv?query=t
#

require 'sinatra/base'
require 'active_record'
require 'csv'
require File.expand_path '../../lib/picky', __FILE__ # Use the current state of Picky.

require_relative 'models'
require_relative 'indexes'
require_relative 'logging'
require_relative 'defaults'

class BookSearch < Sinatra::Application
  
  def self.map url, things
    self.get %r{\A/#{url}\z} do
      things.search(params[:query], params[:ids] || 20, params[:offset] || 0).to_json
    end
  end

  # Set up routes.
  #
  require_relative 'routes'

  # Live.
  #
  live = Picky::Interfaces::LiveParameters::Unicorn.new
  get %r{\A/admin\z} do
    results = live.parameters params
    results.to_json
  end

end