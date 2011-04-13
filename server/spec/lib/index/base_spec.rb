# encoding: utf-8
#
require 'spec_helper'

describe Index::Base do
  
  let(:some_source) { stub :source, :harvest => nil }
  
  context 'initializer' do
    it 'works' do
      expect { described_class.new :some_index_name, some_source }.to_not raise_error
    end
    it 'fails correctly' do
      expect { described_class.new 0, some_source }.to raise_error(<<-ERROR
The index identifier (you gave "0") for Index::Memory/Index::Redis should be a String/Symbol,
Examples:
  Index::Memory.new(:my_cool_index, ...) # Recommended
  Index::Redis.new("a-redis-index", ...)
ERROR
)
    end
    it 'fails correctly' do
      expect { described_class.new :some_index_name, :some_source }.to raise_error(<<-ERROR
The index "some_index_name" should use a data source that responds to either the method #each, or the method #harvest, which yields(id, text).
Or it could use one of the built-in sources:
  Sources::DB,
  Sources::CSV,
  Sources::Delicious,
  Sources::Couch
ERROR
)
    end
    it 'does not fail' do
      expect { described_class.new :some_index_name, [] }.to_not raise_error
    end
    it 'registers with the indexes' do
      @api = described_class.allocate
      
      ::Indexes.should_receive(:register).once.with @api
      
      @api.send :initialize, :some_index_name, some_source
    end
  end
  
  context 'unit' do
    before(:each) do
      @api = described_class.new :some_index_name, some_source
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