# encoding: utf-8
#
require 'spec_helper'

describe IndexAPI do
  
  before(:each) do
    @api = IndexAPI.new :some_index_name, :some_source
  end
  
  describe 'define_category' do
    context 'with block' do
      it 'returns itself' do
        @api.define_category(:some_name){ |indexing, indexed| }.should == @api
      end
      it 'takes a string' do
        @api.define_category(:some_name){ |indexing, indexed| }.should == @api
      end
      it 'yields both the generated indexing category and the indexed category' do
        @api.define_category(:some_name) do |indexing, indexed|
          indexing.should be_kind_of(Indexing::Category)
          indexed.should be_kind_of(Indexed::Category)
        end
      end
    end
    context 'without block' do
      it 'works' do
        lambda { @api.define_category(:some_name) }.should_not raise_error
      end
      it 'returns itself' do
        @api.define_category(:some_name).should == @api
      end
    end
  end
  
end