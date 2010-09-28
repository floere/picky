# encoding: utf-8
require 'spec_helper'

describe Configuration::Type do
  
  before(:each) do
    @field = stub :field, :type= => nil, :virtual? => false
    @field.stub! :dup => @field
    
    @virtual_field = stub :virtual_field, :type= => nil, :virtual? => true
    @virtual_field.stub! :dup => @virtual_field
    @type = Configuration::Type.new :some_name,
                                    :some_indexing_select,
                                    @field,
                                    @virtual_field,
                                    :after_indexing => "some after indexing",
                                    :result_type => :some_result_type,
                                    :heuristics => :some_heuristics,
                                    :ignore_unassigned_tokens => :some_ignore_unassigned_tokens_option,
                                    :solr => :some_solr_option
  end
  
  describe 'solr_fields' do
    it 'should return all non-virtual fields' do
      @type.solr_fields.should == [@field]
    end
  end
  
  describe 'index_solr' do
    it 'should get a new solr indexer and start it' do
      solr = mock :solr
      Indexers::Solr.should_receive(:new).once.with(@type).and_return solr
      
      solr.should_receive(:index).once.with
      
      @type.index_solr
    end
  end
  
  describe 'index' do
    it 'should index each of the fields' do
      @field.should_receive(:index).once.with
      @virtual_field.should_receive(:index).once.with
      
      @type.index
    end
  end
  
end