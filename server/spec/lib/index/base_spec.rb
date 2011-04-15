# encoding: utf-8
#
require 'spec_helper'

describe Index::Base do
  
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


Sources are not passed in as second parameter for Index::Base anymore, but either
* as :source option:
  Index::Base.new(:some_index_name, source: some_source)
or
* given to the #source method inside the config block:
  Index::Base.new(:some_index_name) do
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
    
    describe 'define_source' do
      it 'delegates to the internal indexing' do
        indexing = stub :indexing
        api.stub! :internal_indexing => indexing
        
        indexing.should_receive(:define_source).once.with :some_source
        
        api.define_source :some_source
      end
      it 'has an alias' do
        indexing = stub :indexing
        api.stub! :internal_indexing => indexing
        
        indexing.should_receive(:define_source).once.with :some_source
        
        api.source :some_source
      end
    end
    
    describe 'define_indexing' do
      it 'delegates to the internal indexing' do
        indexing = stub :indexing
        api.stub! :internal_indexing => indexing
        
        indexing.should_receive(:define_indexing).once.with :some_options
        
        api.define_indexing :some_options
      end
      it 'has an alias' do
        indexing = stub :indexing
        api.stub! :internal_indexing => indexing
        
        indexing.should_receive(:define_indexing).once.with :some_options
        
        api.indexing :some_options
      end
    end

    describe 'define_category' do
      context 'with block' do
        it 'returns itself' do
          api.define_category(:some_name){ |indexing, indexed| }.should == api
        end
        it 'takes a string' do
          lambda { api.define_category('some_name'){ |indexing, indexed| } }.should_not raise_error
        end
        it 'yields both the indexing category and the indexed category' do
          api.define_category(:some_name) do |indexing, indexed|
            indexing.should be_kind_of(Internals::Indexing::Category)
            indexed.should be_kind_of(Internals::Indexed::Category)
          end
        end
        it 'yields the indexing category which has the given name' do
          api.define_category(:some_name) do |indexing, indexed|
            indexing.name.should == :some_name
          end
        end
        it 'yields the indexed category which has the given name' do
          api.define_category(:some_name) do |indexing, indexed|
            indexed.name.should == :some_name
          end
        end
      end
      context 'without block' do
        it 'works' do
          lambda { api.define_category(:some_name) }.should_not raise_error
        end
        it 'takes a string' do
          lambda { api.define_category('some_name').should == api }.should_not raise_error
        end
        it 'returns itself' do
          api.define_category(:some_name).should == api
        end
      end
    end
  end
  
end