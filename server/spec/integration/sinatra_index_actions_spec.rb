require 'multi_json'
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
    context 'return values' do
      describe 'update' do
        it 'returns a correct code after updating without problems' do
          result = request.put('/', params: {
                                 index: 'some_index',
                                 data: '{ "id":"1", "name":"Florian", "surname":"Hanke" }'
                               })
          result.status.should == 200
        end
        it 'returns a correct code after updating with just the id' do
          result = request.put('/', params: {
                                 index: 'some_index',
                                 data: '{ "id":"1" }'
                               })
          result.status.should == 200
        end
        it 'returns a correct code after updating without id' do
          result = request.put('/', params: {
                                 index: 'some_index',
                                 data: '{ "name":"Florian", "surname":"Hanke" }'
                               })
          result.status.should == 400
        end
        it 'returns a correct code after updating with the wrong index' do
          result = request.put('/', params: {
                                 index: 'some_wrong_index',
                                 data: '{ "id":"1", "name":"Florian", "surname":"Hanke" }'
                               })
          result.status.should == 404
        end
      end
      describe 'delete' do
        before(:each) do
          request.post('/', params: {
                         index: 'some_index',
                         data: '{ "id":"1", "name":"Florian", "surname":"Hanke" }'
                       })
        end
        it 'returns a correct code after deleting without problems' do
          result = request.delete('/', params: {
                                    index: 'some_index',
                                    data: '{ "id":"1" }'
                                  })
          result.status.should == 200
        end
        it 'returns a correct code after deleting twice' do
          request.delete('/', params: {
                           index: 'some_index',
                           data: '{ "id":"1" }'
                         })
          result = request.delete('/', params: {
                                    index: 'some_index',
                                    data: '{ "id":"1" }'
                                  })
          result.status.should == 200
        end
        it 'returns a correct code after deleting without id' do
          result = request.delete('/', params: {
                                    index: 'some_index',
                                    data: '{}'
                                  })
          result.status.should == 400
        end
        it 'returns a correct code after deleting with the wrong index' do
          result = request.delete('/', params: {
                                    index: 'some_wrong_index',
                                    data: '{ "id":"1" }'
                                  })
          result.status.should == 404
        end
      end
    end
    context '' do
      it 'updates the index correctly' do
        request.put('/', params: {
                      index: 'some_index',
                      data: '{ "id":"1", "name":"Florian", "surname":"Hanke" }'
                    })

        results = MultiJson.decode request.get('/people', params: { query: 'florian' }).body
        results['total'].should

        request.put('/', params: {
                      index: 'some_index',
                      data: '{ "id":"2", "name":"Florian", "surname":"Meier" }'
                    })

        results = MultiJson.decode request.get('/people', params: { query: 'florian' }).body
        results['total'].should == 2
      end
      it 'updates the index correctly' do
        request.put('/', params: {
                      index: 'some_index',
                      data: '{ "id":"1", "name":"Flarian", "surname":"Hanke" }'
                    })

        results = MultiJson.decode request.get('/people', params: { query: 'hanke' }).body
        results['total'].should

        results = MultiJson.decode request.get('/people', params: { query: 'florian' }).body
        results['total'].should

        # Whoops, typo. Let's fix it.
        #
        request.put('/', params: {
                      index: 'some_index',
                      data: '{ "id":"1", "name":"Florian", "surname":"Hanke" }'
                    })

        results = MultiJson.decode request.get('/people', params: { query: 'hanke' }).body
        results['total'].should

        results = MultiJson.decode request.get('/people', params: { query: 'flarian' }).body
        results['total'].should

        results = MultiJson.decode request.get('/people', params: { query: 'florian' }).body
        results['total'].should == 1
      end
      it 'deletes entries from the index correctly' do
        request.put('/', params: {
                      index: 'some_index',
                      data: '{ "id":"1", "name":"Florian", "surname":"Hanke" }'
                    })
        request.put('/', params: {
                      index: 'some_index',
                      data: '{ "id":"2", "name":"Florian", "surname":"Meier" }'
                    })

        results = MultiJson.decode request.get('/people', params: { query: 'florian' }).body
        results['total'].should

        request.delete('/', params: {
                         index: 'some_index',
                         data: '{ "id":"1" }'
                       })

        results = MultiJson.decode request.get('/people', params: { query: 'florian' }).body
        results['total'].should == 1
      end
      it 'has no problem with a superfluous delete' do
        request.delete('/', params: {
                         index: 'some_index',
                         data: '{ "id":"1" }'
                       })

        results = MultiJson.decode request.get('/people', params: { query: 'florian' }).body
        results['total'].should == 0
      end
      it 'works with the (test) client' do
        client = Picky::TestClient.new MyIndexActionsPickyServer, path: '/people'

        request.put('/', params: {
                      index: 'some_index',
                      data: '{ "id":"1", "name":"Florian", "surname":"Hanke" }'
                    })

        client.search('florian').total.should == 1
      end
    end
  end
end
