require 'yajl'
require 'sinatra'
require_relative '../../../client/lib/picky-client'
require_relative '../../../client/lib/picky-client/spec'
require 'spec_helper'

describe 'Sinatra Index Actions' do
  
  before(:all) do
    
    # This is the application that is tested.
    #
    class MyIndexActionsPickyServer < Sinatra::Base
      extend Picky::Sinatra::IndexActions
    
      data = Picky::Index.new :some_index do
        category :name
        category :surname
      end
    
      people = Picky::Search.new data
    
      get '/people' do
        results = people.search params[:query], params[:ids] || 20, params[:offset] || 0
        results.to_json
      end
    end
    
  end
  
  describe 'updating' do
    before(:each) do
      Picky::Indexes.clear
    end
    let(:request) { ::Rack::MockRequest.new MyIndexActionsPickyServer }
    it 'updates the index correctly' do
      request.post('/', params: {
        index: 'some_index',
        data: %Q{{ "id":"1", "name":"Florian", "surname":"Hanke" }}
      })
      
      results = Yajl::Parser.parse request.get('/people', params: { query: 'florian' }).body
      results['total'].should == 1
      
      request.post('/', params: {
        index: 'some_index',
        data: %Q{{ "id":"2", "name":"Florian", "surname":"Meier" }}
      })
      
      results = Yajl::Parser.parse request.get('/people', params: { query: 'florian' }).body
      results['total'].should == 2
    end
    it 'updates the index correctly' do
      request.post('/', params: {
        index: 'some_index',
        data: %Q{{ "id":"1", "name":"Flarian", "surname":"Hanke" }}
      })
      
      results = Yajl::Parser.parse request.get('/people', params: { query: 'hanke' }).body
      results['total'].should == 1
      
      results = Yajl::Parser.parse request.get('/people', params: { query: 'florian' }).body
      results['total'].should == 0
      
      # Whoops, typo. Let's fix it.
      #
      request.post('/', params: {
        index: 'some_index',
        data: %Q{{ "id":"1", "name":"Florian", "surname":"Hanke" }}
      })
      
      results = Yajl::Parser.parse request.get('/people', params: { query: 'hanke' }).body
      results['total'].should == 1
      
      results = Yajl::Parser.parse request.get('/people', params: { query: 'flarian' }).body
      results['total'].should == 0
      
      results = Yajl::Parser.parse request.get('/people', params: { query: 'florian' }).body
      results['total'].should == 1
    end
    it 'deletes entries from the index correctly' do
      request.post('/', params: {
        index: 'some_index',
        data: %Q{{ "id":"1", "name":"Florian", "surname":"Hanke" }}
      })
      request.post('/', params: {
        index: 'some_index',
        data: %Q{{ "id":"2", "name":"Florian", "surname":"Meier" }}
      })
      
      results = Yajl::Parser.parse request.get('/people', params: { query: 'florian' }).body
      results['total'].should == 2
      
      request.delete('/', params: {
        index: 'some_index',
        data: %Q{{ "id":"1" }}
      })
      
      results = Yajl::Parser.parse request.get('/people', params: { query: 'florian' }).body
      results['total'].should == 1
    end
    it 'has no problem with a superfluous delete' do
      request.delete('/', params: {
        index: 'some_index',
        data: %Q{{ "id":"1" }}
      })
      
      results = Yajl::Parser.parse request.get('/people', params: { query: 'florian' }).body
      results['total'].should == 0
    end
    it 'works with the (test) client' do
      client = Picky::TestClient.new MyIndexActionsPickyServer, :path => '/people'
      
      request.post('/', params: {
        index: 'some_index',
        data: %Q{{ "id":"1", "name":"Florian", "surname":"Hanke" }}
      })
      
      client.search('florian').total.should == 1
    end
  end
  
end