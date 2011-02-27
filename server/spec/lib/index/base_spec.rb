# encoding: utf-8
#
require 'spec_helper'

describe Index::Base do
  
  context 'initializer' do
    it 'works' do
      lambda { described_class.new :some_index_name, :some_source }.should_not raise_error
    end
    it 'registers with the indexes' do
      @api = described_class.allocate
      
      ::Indexes.should_receive(:register).once.with @api
      
      @api.send :initialize, :some_index_name, :some_source
    end
  end
  
  context 'unit' do
    before(:each) do
      @api = described_class.new :some_index_name, :some_source
    end

    describe 'define_category' do
      context 'with block' do
        it 'returns itself' do
          @api.define_category(:some_name){ |indexing, indexed| }.should == @api
        end
        it 'takes a string' do
          lambda { @api.define_category('some_name'){ |indexing, indexed| } }.should_not raise_error
        end
        it 'yields both the indexing category and the indexed category' do
          @api.define_category(:some_name) do |indexing, indexed|
            indexing.should be_kind_of(Internals::Indexing::Category)
            indexed.should be_kind_of(Internals::Indexed::Category)
          end
        end
        it 'yields the indexing category which has the given name' do
          @api.define_category(:some_name) do |indexing, indexed|
            indexing.name.should == :some_name
          end
        end
        it 'yields the indexed category which has the given name' do
          @api.define_category(:some_name) do |indexing, indexed|
            indexed.name.should == :some_name
          end
        end
      end
      context 'without block' do
        it 'works' do
          lambda { @api.define_category(:some_name) }.should_not raise_error
        end
        it 'takes a string' do
          lambda { @api.define_category('some_name').should == @api }.should_not raise_error
        end
        it 'returns itself' do
          @api.define_category(:some_name).should == @api
        end
      end
    end
  end
  
end