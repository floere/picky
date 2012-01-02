require 'net/http'
require 'uri'

module Picky
  
  def self.Indexer options = {}
    host = options[:host] || 'localhost'
    port = options[:port] || 8080
    path = options[:path] || '/update'
    
    Module.new do
      uri = URI::HTTP.new 'http', nil, host, port, nil, path, nil, nil, nil, nil, nil
      
      define_method :index do
        Net::HTTP.post_form uri, data: to_json
      end
      
    end
  end
  
end