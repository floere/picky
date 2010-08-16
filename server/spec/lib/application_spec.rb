# encoding: utf-8
#
require 'spec_helper'

describe Application do
  
  describe 'call' do
    before(:each) do
      @routes = stub :routes
      Application.stub! :routes => @routes
    end
    it 'should delegate' do
      @routes.should_receive(:call).once.with :env
      
      Application.call :env
    end
  end
  
  describe 'reset_routes' do
    it 'should return a new Routing instance' do
      Application.reset_routes.should be_kind_of(Routing)
    end
  end
  
  describe 'routes' do
    before(:each) do
      Application.instance_variable_set :@routes, nil
    end
    it 'should generate a new routes object if one has not been generated' do
      Application.should_receive(:reset_routes).once
      
      Application.routes
    end
    it 'should not generate a new routes object if it has been called before' do
      Application.routes
      
      Application.should_receive(:reset_routes).never
      
      Application.routes
    end
  end
  
  describe 'routing' do
    it 'should be there' do
      lambda { Application.routing do end }.should_not raise_error
    end
    it 'needs a block' do
      lambda { Application.routing }.should raise_error(ArgumentError)
    end
    context 'with routing' do
      before(:each) do
        Application.reset_routes
      end
      it 'should set defaults' do
        Application.routes.should_receive(:defaults).once.with :a => :b
        
        Application.routing :a => :b do
          
        end
      end
      it 'should instance eval on the routing' do
        Application.routes.should_receive(:flarb).once.with :glorb
        
        Application.routing do
          flarb :glorb
        end
      end
    end
  end
  
end