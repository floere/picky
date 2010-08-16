# encoding: utf-8
require 'spec_helper'

describe Solr::SchemaGenerator do

  before(:each) do
    @types = stub :types
    @configuration = stub :configuration, :types => @types
    @generator = Solr::SchemaGenerator.new @configuration
  end

  describe 'bound_field_names' do
    before(:each) do
      @generator.stub! :combine_field_names => :some_field_names
    end
    it 'should bind field_names' do
      b = @generator.bound_field_names

      eval('field_names', b).should == :some_field_names
    end
  end

  describe 'generate' do
    before(:each) do
      @generator.stub! :bound_field_names
      @generator.stub! :generate_schema_for
    end
    it 'should receive generate_schema_for once with the result of extract_binding' do
      @generator.stub! :bound_field_names => :some_binding

      @generator.should_receive(:generate_schema_for).once.with :some_binding

      @generator.generate
    end
    it 'should extract the binding' do
      @generator.should_receive(:bound_field_names).once.with

      @generator.generate
    end
  end

end