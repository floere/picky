# encoding: utf-8
#
require 'spec_helper'

describe Indexes::Base do
  
  let(:some_source) { stub :source, :harvest => nil, :inspect => 'some_source' }
  
  context 'initializer' do
    it 'works' do
      expect { described_class.new :some_index_name, source: some_source }.to_not raise_error
    end
    it 'fails correctly' do
      expect { described_class.new 0, some_source }.to raise_error
    end
    it 'fails correctly' do
      expect { described_class.new :some_index_name, source: :some_source }.to raise_error
    end
    it 'fails with a good message deprecated way of source passing is used' do
      expect { described_class.new :some_index_name, some_source }.to raise_error(<<-ERROR


Sources are not passed in as second parameter for Indexes::Base anymore, but either
* as :source option:
  Indexes::Base.new(:some_index_name, source: some_source)
or
* given to the #source method inside the config block:
  Indexes::Base.new(:some_index_name) do
    source some_source
  end

Sorry about that breaking change (in 2.2.0), didn't want to go to 3.0.0 yet!

All the best
  -- Picky


ERROR
)
    end
    it 'does not fail' do
      expect { described_class.new :some_index_name, source: [] }.to_not raise_error
    end
    it 'registers with the indexes' do
      @api = described_class.allocate
      
      ::Indexes.should_receive(:register).once.with @api
      
      @api.send :initialize, :some_index_name, source: some_source
    end
  end
  
  context 'unit' do
    let(:api) { described_class.new :some_index_name, source: some_source }
    
    describe 'geo_categories' do
      it 'delegates correctly' do
        api.should_receive(:ranged_category).once.with :some_lat, 0.00898312, from: :some_lat_from
        api.should_receive(:ranged_category).once.with :some_lng, 0.01796624, from: :some_lng_from
        
        api.geo_categories :some_lat, :some_lng, 1, :lat_from => :some_lat_from, :lng_from => :some_lng_from
      end
    end

    describe 'define_category' do
      context 'with block' do
        it 'returns the category' do
          expected = nil
          api.define_category(:some_name){ |category| expected = category }.should == expected
        end
        it 'takes a string' do
          lambda { api.define_category('some_name'){ |indexing, indexed| } }.should_not raise_error
        end
        it 'yields both the indexing category and the indexed category' do
          api.define_category(:some_name) do |category|
            category.should be_kind_of(Category)
          end
        end
        it 'yields the category which has the given name' do
          api.define_category(:some_name) do |category|
            category.name.should == :some_name
          end
        end
      end
      context 'without block' do
        it 'works' do
          lambda { api.define_category(:some_name) }.should_not raise_error
        end
        it 'takes a string' do
          lambda { api.define_category('some_name') }.should_not raise_error
        end
        it 'returns itself' do
          api.define_category(:some_name).should be_kind_of(Category)
        end
      end
    end
  end
  
end