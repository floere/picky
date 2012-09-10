# encoding: utf-8
#
require 'active_support/json'
require 'sinatra/base'
begin
  require File.expand_path '../../../../lib/picky', __FILE__
rescue LoadError
  require 'picky'
end


class ExternalDataSearch < Sinatra::Base

  include Picky
  extend Sinatra::IndexActions
  
  def initialize
    at_exit { data.dump }
  end
  
  def data
    @data ||= Index.new :models do
      category :id
      category :name
      category :surname
    end
  end
  
  def finder
    @finder ||= Search.new data
  end
  
  post %r{\A/update\z} do # PUT?
    hash = JSON.parse params['data']
    data.replace_from hash
    puts "UPDATING from #{hash}"
  end
  
  get %r{\A/search\z} do
    results = finder.search params['query'], params['ids'] || 20, params['offset'] || 0
    results.to_json
  end

end

# Was this code below, but people don't get contexts etc.
#
# class ExternalDataSearch < Sinatra::Base
# 
#   include Picky
#   extend Sinatra::IndexActions
#   
#   data = Index.new :models do
#     category :id
#     category :name
#     category :surname
#   end
#   post %r{\A/update\z} do # PUT?
#     hash = JSON.parse params['data']
#     data.replace_from hash
#     puts "UPDATING from #{hash}"
#   end
#   at_exit { data.dump }
#   
#   models = Search.new data
#   get %r{\A/search\z} do
#     results = models.search params['query'], params['ids'] || 20, params['offset'] || 0
#     results.to_json
#   end
# 
# end