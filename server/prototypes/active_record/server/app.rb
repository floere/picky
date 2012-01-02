# encoding: utf-8
#
require 'active_support/json'
require 'sinatra/base'
require File.expand_path '../../../../lib/picky', __FILE__

class ExternalDataSearch < Sinatra::Application

  include Picky
  extend Picky::Sinatra
  
  data = Index.new :models do
    category :id
    category :name
    category :surname
  end
  post %r{\A/update\z} do
    hash = JSON.parse params['data']
    data.replace_from hash
    puts "UPDATING from #{hash}"
  end
  at_exit { data.dump }
  
  models = Search.new data
  get %r{\A/search\z} do
    results = models.search params['query'], params['ids'] || 20, params['offset'] || 0
    results.to_json
  end

end