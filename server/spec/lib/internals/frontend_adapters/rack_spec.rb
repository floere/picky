# encoding: utf-8
#
require 'spec_helper'

describe Internals::FrontendAdapters::Rack do
  
  before(:each) do
    @rack_adapter = described_class.new
    @rack_adapter.stub! :exclaim
  end
  
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
  
  context 'empty?' do
    context 'no routes' do
      before(:each) do
        @rack_adapter.reset_routes
      end
      it 'returns the right answer' do
        @rack_adapter.empty?.should == true
      end
    end
    context 'with routes' do
      before(:each) do
        @rack_adapter.route %r{something} => Search.new
      end
      it 'returns the right answer' do
        @rack_adapter.empty?.should == false
      end
    end
  end
  
  context 'real routes' do
    before(:each) do
      @rack_adapter.reset_routes
      PickyLog.stub! :log
    end
    it 'should route correctly' do
      env = {}
      
      @rack_adapter.routes.freeze
      @rack_adapter.call(env).should == [404, {"Content-Type" => "text/html", "X-Cascade" => "pass"}, ["Not Found"]]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/'
      
      @rack_adapter.root 200
      
      @rack_adapter.routes.freeze
      @rack_adapter.call(env).should == [200, {"Content-Type"=>"text/html", "Content-Length"=>"0"}, ['']]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/blarf'
      
      @rack_adapter.default 200
      
      @rack_adapter.routes.freeze
      @rack_adapter.call(env).should == [200, {"Content-Type"=>"text/html", "Content-Length"=>"0"}, ['']]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/gurk'
      
      @rack_adapter.answer %r{/gurk}, lambda { |env| [333, {}, ['this is gurk']] }
      
      @rack_adapter.routes.freeze
      @rack_adapter.call(env).should == [333, {}, ['this is gurk']]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/gurk'
      
      @rack_adapter.answer '/gurk', lambda { |env| [333, {}, ['this is gurk']] }
      
      @rack_adapter.routes.freeze
      @rack_adapter.call(env).should == [333, {}, ['this is gurk']]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/searches/some_route?query=some_query'
      
      search = stub :search
      search.should_receive(:search_with_text).once.with(anything, 20, 0).and_return(Internals::Results.new)
      Search.stub! :new => search
      
      @rack_adapter.route '/searches/some_route' => Search.new(:some_index, :some_other_index)
      
      @rack_adapter.routes.freeze
      @rack_adapter.call(env).should == [200, {"Content-Type"=>"application/json", "Content-Length"=>"52"}, ["{\"allocations\":[],\"offset\":0,\"duration\":0,\"total\":0}"]]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/searches/some_route?query=some_query&type=some_type'
      
      search = stub :search
      search.should_receive(:search_with_text).once.with(anything, 20, 0).and_return(Internals::Results.new)
      Search.stub! :new => search
      
      @rack_adapter.route '/searches/some_route' => Search.new(:some_index, :some_other_index), :query => { :type => :some_type }
      
      @rack_adapter.routes.freeze
      @rack_adapter.call(env).should == [200, {"Content-Type"=>"application/json", "Content-Length"=>"52"}, ["{\"allocations\":[],\"offset\":0,\"duration\":0,\"total\":0}"]]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/searches/some_wrong_route?query=some_query'
      
      search = stub :search
      search.should_receive(:search_with_text).never
      Search.stub! :new => search
      
      @rack_adapter.route '/searches/some_route' => Search.new(:some_index, :some_other_index)
      
      @rack_adapter.routes.freeze
      @rack_adapter.call(env).should == [404, {"Content-Type"=>"text/html", "X-Cascade"=>"pass"}, ["Not Found"]]
    end
  end
  
  context 'stubbed routes' do
    before(:each) do
      @routes = stub :routes
      @rack_adapter.stub! :routes => @routes
    end
    
    describe 'generate_query_string' do
      it 'should not allow an empty query condition' do
        lambda {
          @rack_adapter.generate_query_string({}).should == 'this=must_be'
        }.should raise_error "At least one query string condition is needed."
      end
      it 'should handle a single condition' do
        @rack_adapter.generate_query_string(:this => :must_be).should == 'this=must_be'
      end
      it 'should not allow multiple query strings' do
        lambda {
          @rack_adapter.generate_query_string(:this => :must_be, :that => :should_be).should == 'this=must_be|that=should_be'
        }.should raise_error "Too many query param conditions (only 1 allowed): {:this=>:must_be, :that=>:should_be}"
      end
      it 'should be sanity checked' do
        '/searches/some_route?query=some_query&type=some_type'.should match(%r{#{"type=some_type"}})
      end
    end
    
    describe "route" do
      it "should delegate correctly" do
        @rack_adapter.should_receive(:route_one).once.with %r{regexp1}, :query1, {}
        @rack_adapter.should_receive(:route_one).once.with %r{regexp2}, :query2, {}
        
        @rack_adapter.route %r{regexp1} => :query1, %r{regexp2} => :query2
      end
      it "should split options correctly" do
        @rack_adapter.should_receive(:route_one).once.with %r{regexp1}, :query1, :some => :option
        @rack_adapter.should_receive(:route_one).once.with %r{regexp2}, :query2, :some => :option
        
        @rack_adapter.route %r{regexp1} => :query1, %r{regexp2} => :query2, :some => :option
      end
      it 'does not accept nil queries' do
        lambda { @rack_adapter.route %r{some/regexp} => nil }.should raise_error(Internals::FrontendAdapters::Rack::RouteTargetNilError, /Routing for \/some\\\/regexp\/ was defined with a nil target object, i.e. \/some\\\/regexp\/ => nil./)
      end
    end
    
    describe 'finalize' do
      before(:each) do
        @rack_adapter.routes.should_receive(:freeze).once.with
        
        @rack_adapter.finalize
      end
    end
    
    describe 'route_one' do
      before(:each) do
        Internals::Adapters::Rack.stub! :app_for => :some_query_app
      end
      it 'should add the right route' do
        @routes.should_receive(:add_route).once.with :some_query_app, { :request_method => "GET", :path_info => /some_url/ }, {}, "some_query"
        
        @rack_adapter.route_one %r{some_url}, :some_query, {}
      end
      it 'should add the right route' do
        @routes.should_receive(:add_route).once.with :some_query_app, { :request_method => "GET", :path_info => /some_url/ }, {}, "some_query"
        
        @rack_adapter.route_one 'some_url', :some_query, {}
      end
      it 'should add the right route' do
        @routes.should_receive(:add_route).once.with :some_query_app, { :request_method => "GET", :glarf => :blarf, :path_info => /some_url/ }, {}, "some_query"
        
        @rack_adapter.route_one 'some_url', :some_query, { :glarf => :blarf }
      end
    end
    
    describe 'default' do
      it 'should call answer' do
        @rack_adapter.should_receive(:answer).once.with nil, Internals::FrontendAdapters::Rack::STATUSES[200]
        
        @rack_adapter.default 200
      end
    end
    
    describe 'root' do
      it 'should call answer' do
        @rack_adapter.should_receive(:answer).once.with %r{^/$}, Internals::FrontendAdapters::Rack::STATUSES[200]
        
        @rack_adapter.root 200
      end
      it 'should call answer' do
        @rack_adapter.should_receive(:answer).once.with %r{^/$}, Internals::FrontendAdapters::Rack::STATUSES[404]
        
        @rack_adapter.root 404
      end
    end
    
    describe 'answer' do
      context 'with app' do
        before(:each) do
          @app = stub :app
        end
        context 'with url' do
          it 'should use the app with default_options from the url' do
            @routes.should_receive(:add_route).once.with @app, { :request_method => "GET", :path_info => /some_url/ }
            
            @rack_adapter.answer 'some_url', @app
          end
        end
        context 'without url' do
          it 'should use the app with default_options' do
            @routes.should_receive(:add_route).once.with @app, { :request_method => "GET" }
            
            @rack_adapter.answer nil, @app
          end
        end
      end
      context 'without app' do
        context 'with url' do
          it 'should use the 404 with default_options from the url' do
            @routes.should_receive(:add_route).once.with Internals::FrontendAdapters::Rack::STATUSES[200], { :request_method => "GET", :path_info => /some_url/ }
            
            @rack_adapter.answer 'some_url'
          end
        end
        context 'without url' do
          it 'should use the 404 with default_options' do
            @routes.should_receive(:add_route).once.with Internals::FrontendAdapters::Rack::STATUSES[200], { :request_method => "GET" }
            
            @rack_adapter.answer
          end
        end
      end
    end
    
  end
  
end