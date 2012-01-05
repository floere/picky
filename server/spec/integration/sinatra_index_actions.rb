require 'Yajl'
require 'sinatra'
require 'picky-client'
require 'spec_helper'

describe 'Sinatra Index Actions' do
  
  class MyPickyServer < Sinatra::Base
    extend Picky::Sinatra::IndexActions
    
    data = Picky::Index.new :index do
      category :name
      category :surname
    end
    people = Picky::Search.new data
    
    get '/people' do
      results = people.search params[:query], params[:ids] || 20, params[:offset] || 0
      results.to_json
    end
  end
  
  describe 'updating' do
    let(:request) { ::Rack::MockRequest.new MyPickyServer }
    it 'should update the index correctly' do
      request.post('/', params: { index: 'index', data: { id: "1", name: "Florian", surname: "Hanke" } })
      
      results = Yajl::Parser.parse request.get('/people', params: { query: 'florian' }).body
      results['total'].should == 1
      
      request.post('/', params: { index: 'index', data: { id: "2", name: "Florian", surname: "Meier" } })
      
      results = Yajl::Parser.parse request.get('/people', params: { query: 'florian' }).body
      results['total'].should == 2
    end
  end
  
end