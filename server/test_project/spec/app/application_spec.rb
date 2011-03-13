# coding: utf-8
#
require 'spec_helper'

describe BookSearch do
  
  def rack_defaults_for url
    url, query_string = url.split ??
    
    { "GATEWAY_INTERFACE"=>"CGI/1.1",
      "PATH_INFO"=>"#{url}",
      "QUERY_STRING"=>"#{query_string}",
      "REMOTE_ADDR"=>"127.0.0.1",
      "REMOTE_HOST"=>"localhost",
      "REQUEST_METHOD"=>"GET",
      "REQUEST_URI"=>"http://localhost:3001#{url}",
      "SCRIPT_NAME"=>"",
      "SERVER_NAME"=>"localhost",
      "SERVER_PORT"=>"3001",
      "SERVER_PROTOCOL"=>"HTTP/1.1",
      "SERVER_SOFTWARE"=>"WEBrick/1.3.1 (Ruby/1.9.2/2010-07-11)",
      "HTTP_HOST"=>"localhost:3001",
      "HTTP_USER_AGENT"=>"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_8; en-us) AppleWebKit/533.16 (KHTML like Gecko) Version/5.0 Safari/533.16",
      "HTTP_ACCEPT"=>"application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5",
      "HTTP_CACHE_CONTROL"=>"max-age=0",
      "HTTP_ACCEPT_LANGUAGE"=>"en-us",
      "HTTP_ACCEPT_ENCODING"=>"gzip,
      deflate",
      "HTTP_COOKIE"=>"__utma=111872281.1536032598.1255697925.1255697925.1255697925.1; _jsuid=8971917605087477351; locale=de",
      "HTTP_CONNECTION"=>"keep-alive",
      "rack.input"=>'' }
  end
  
  def self.it_should_route path, status
    it "should route #{path} and answer with #{status}" do
      described_class.call(rack_defaults_for(path))[0].should == status
    end
  end
  
  it_should_route '/blorg/gnorg', 404
  
  it_should_route '/books/full?query=', 200
  it_should_route '/books/live?query=', 200
  
  it_should_route '/isbn/full?query=', 200
  
  it_should_route '/isbn/ful?query=blarf', 404
  
  it_should_route '/', 200
  
end