# encoding: utf-8
#
require 'spec_helper'

describe Routing do
  
  before(:each) do
    @routing = Routing.new
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
  
  context 'real routes' do
    before(:each) do
      @routing.reset_routes
      PickyLog.stub! :log
    end
    it 'should route correctly' do
      env = {}
      
      @routing.routes.freeze
      @routing.call(env).should == [404, {"Content-Type" => "text/html", "X-Cascade" => "pass"}, ["Not Found"]]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/'
      
      @routing.root 200
      
      @routing.routes.freeze
      @routing.call(env).should == [200, {"Content-Type"=>"text/html", "Content-Length"=>"0"}, ['']]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/blarf'
      
      @routing.default 200
      
      @routing.routes.freeze
      @routing.call(env).should == [200, {"Content-Type"=>"text/html", "Content-Length"=>"0"}, ['']]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/gurk'
      
      @routing.answer %r{/gurk}, lambda { |env| [333, {}, ['this is gurk']] }
      
      @routing.routes.freeze
      @routing.call(env).should == [333, {}, ['this is gurk']]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/gurk'
      
      @routing.answer '/gurk', lambda { |env| [333, {}, ['this is gurk']] }
      
      @routing.routes.freeze
      @routing.call(env).should == [333, {}, ['this is gurk']]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/searches/live.json?query=some_query'
      
      live = stub :live
      live.should_receive(:search_with_text).once.with(anything, 0).and_return(Results::Live.new)
      Query::Live.stub! :new => live
      
      @routing.live %r{/searches/live}, :some_index
      
      @routing.routes.freeze
      @routing.call(env).should == [200, {"Content-Type"=>"application/octet-stream", "Content-Length"=>"52"}, ["{\"allocations\":[],\"offset\":0,\"duration\":0,\"total\":0}"]]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/searches/live.json?query=some_query'
      
      live = stub :live
      live.should_receive(:search_with_text).once.with(anything, 0).and_return(Results::Live.new)
      Query::Live.stub! :new => live
      
      @routing.live '/searches/live', :some_index
      
      @routing.routes.freeze
      @routing.call(env).should == [200, {"Content-Type"=>"application/octet-stream", "Content-Length"=>"52"}, ["{\"allocations\":[],\"offset\":0,\"duration\":0,\"total\":0}"]]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/searches/full?query=some_query'
      
      full = stub :full
      full.should_receive(:search_with_text).once.with(anything, 0).and_return(Results::Full.new)
      Query::Full.stub! :new => full
      
      @routing.full %r{/searches/full}, :some_index
      
      @routing.routes.freeze
      @routing.call(env).should == [200, {"Content-Type"=>"application/octet-stream", "Content-Length"=>"50"}, ["\x04\b{\t:\x10allocations[\x00:\voffseti\x00:\rdurationi\x00:\ntotali\x00"]]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/searches/full?query=some_query'
      
      full = stub :full
      full.should_receive(:search_with_text).once.with(anything, 0).and_return(Results::Full.new)
      Query::Full.stub! :new => full
      
      @routing.full '/searches/full', :some_index
      
      @routing.routes.freeze
      @routing.call(env).should == [200, {"Content-Type"=>"application/octet-stream", "Content-Length"=>"50"}, ["\x04\b{\t:\x10allocations[\x00:\voffseti\x00:\rdurationi\x00:\ntotali\x00"]]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/searches/some_route?query=some_query'
      
      full = stub :full
      full.should_receive(:search_with_text).once.with(anything, 0).and_return(Results::Full.new)
      Query::Full.stub! :new => full
      
      @routing.route '/searches/some_route', Query::Full.new(:some_index, :some_other_index)
      
      @routing.routes.freeze
      @routing.call(env).should == [200, {"Content-Type"=>"application/octet-stream", "Content-Length"=>"50"}, ["\x04\b{\t:\x10allocations[\x00:\voffseti\x00:\rdurationi\x00:\ntotali\x00"]]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/searches/some_route?query=some_query&type=some_type'
      
      full = stub :full
      full.should_receive(:search_with_text).once.with(anything, 0).and_return(Results::Full.new)
      Query::Full.stub! :new => full
      
      @routing.route '/searches/some_route', Query::Full.new(:some_index, :some_other_index), :query => { :type => :some_type }
      
      @routing.routes.freeze
      @routing.call(env).should == [200, {"Content-Type"=>"application/octet-stream", "Content-Length"=>"50"}, ["\x04\b{\t:\x10allocations[\x00:\voffseti\x00:\rdurationi\x00:\ntotali\x00"]]
    end
    it 'should route correctly' do
      env = rack_defaults_for '/searches/some_wrong_route?query=some_query'
      
      full = stub :full
      full.should_receive(:search_with_text).never
      Query::Full.stub! :new => full
      
      @routing.route '/searches/some_route', Query::Full.new(:some_index, :some_other_index)
      
      @routing.routes.freeze
      @routing.call(env).should == [404, {"Content-Type"=>"text/html", "X-Cascade"=>"pass"}, ["Not Found"]]
    end
  end
  
  context 'stubbed routes' do
    before(:each) do
      @routes = stub :routes
      @routing.stub! :routes => @routes
    end
    describe 'call' do
      it 'should description' do
        
      end
    end
    
    describe 'generate_query_string' do
      it 'should not allow an empty query condition' do
        lambda {
          @routing.generate_query_string({}).should == 'this=must_be'
        }.should raise_error "At least one query string condition is needed."
      end
      it 'should handle a single condition' do
        @routing.generate_query_string(:this => :must_be).should == 'this=must_be'
      end
      it 'should not allow multiple query strings' do
        lambda {
          @routing.generate_query_string(:this => :must_be, :that => :should_be).should == 'this=must_be|that=should_be'
        }.should raise_error "Too many query param conditions (only 1 allowed): {:this=>:must_be, :that=>:should_be}"
      end
      it 'should be sanity checked' do
        '/searches/some_route?query=some_query&type=some_type'.should match(%r{#{"type=some_type"}})
      end
    end
    
    describe 'route' do
      before(:each) do
        @some_query_app = stub :some_query_app
        @routing.stub! :generate_app => @some_query_app
      end
      it 'should add the right route' do
        @routes.should_receive(:add_route).once.with @some_query_app, { :request_method => "GET", :path_info => /some_url/ }
        
        @routing.route %r{some_url}, :some_query, {}
      end
      it 'should add the right route' do
        @routes.should_receive(:add_route).once.with @some_query_app, { :request_method => "GET", :path_info => /some_url/ }
        
        @routing.route 'some_url', :some_query, {}
      end
      it 'should add the right route' do
        @routes.should_receive(:add_route).once.with @some_query_app, { :request_method => "GET", :glarf => :blarf, :path_info => /some_url/ }
        
        @routing.route 'some_url', :some_query, { :glarf => :blarf }
      end
    end
    
    describe 'default' do
      it 'should call answer' do
        @routing.should_receive(:answer).once.with nil, Routing::STATUSES[200]
        
        @routing.default 200
      end
    end
    
    describe 'root' do
      it 'should call answer' do
        @routing.should_receive(:answer).once.with %r{^/$}, Routing::STATUSES[200]
        
        @routing.root 200
      end
    end
    
    # 
    describe 'live' do
      describe 'instance creation' do
        before(:each) do
          @routing.stub :route
        end
        context 'with options' do
          it 'should call route correctly' do
            Query::Live.should_receive(:new).once.with :some_index, :some_other_index
            
            @routing.live :url, :some_index, :some_other_index, { :query => { :param => :value } }
          end
        end
        context 'without options' do
          it 'should call route correctly' do
            Query::Live.should_receive(:new).once.with :some_index, :some_other_index
            
            @routing.live :url, :some_index, :some_other_index
          end
        end
      end
      describe 'delegation' do
        context 'with options' do
          it 'should call route correctly' do
            Query::Live.stub! :new => :live
            
            @routing.should_receive(:route).once.with :url, :live, { :query => { :param => :value } }
            
            @routing.live :url, :some_index, { :query => { :param => :value } }
          end
        end
        context 'without options' do
          it 'should call route correctly' do
            Query::Live.stub! :new => :live
            
            @routing.should_receive(:route).once.with :url, :live, {}
            
            @routing.live :url, :some_index
          end
        end
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
            
            @routing.answer 'some_url', @app
          end
        end
        context 'without url' do
          it 'should use the app with default_options' do
            @routes.should_receive(:add_route).once.with @app, { :request_method => "GET" }
            
            @routing.answer nil, @app
          end
        end
      end
      context 'without app' do
        context 'with url' do
          it 'should use the 404 with default_options from the url' do
            @routes.should_receive(:add_route).once.with Routing::STATUSES[200], { :request_method => "GET", :path_info => /some_url/ }
            
            @routing.answer 'some_url'
          end
        end
        context 'without url' do
          it 'should use the 404 with default_options' do
            @routes.should_receive(:add_route).once.with Routing::STATUSES[200], { :request_method => "GET" }
            
            @routing.answer
          end
        end
      end
    end
    
  end
  
end