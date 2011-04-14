require 'spec_helper'

describe Internals::Indexing::Category do
  
  before(:each) do
    @index  = stub :index, :name => :some_index
    @source = stub :some_given_source, :key_format => nil
  end
  let(:category) { described_class.new(:some_category, @index, :source => @source).tap { |c| c.stub! :timed_exclaim } }
  
  context "unit specs" do
    let(:exact) { category.exact }
    let(:partial) { category.partial }
    
    describe 'backup_caches' do
      it 'delegates to both bundles' do
        exact.should_receive(:backup).once.with()
        partial.should_receive(:backup).once.with()
        
        category.backup_caches
      end
    end
    describe 'restore_caches' do
      it 'delegates to both bundles' do
        exact.should_receive(:restore).once.with()
        partial.should_receive(:restore).once.with()
        
        category.restore_caches
      end
    end
    describe 'check_caches' do
      it 'delegates to both bundles' do
        exact.should_receive(:raise_unless_cache_exists).once.with()
        partial.should_receive(:raise_unless_cache_exists).once.with()
        
        category.check_caches
      end
    end
    describe 'clear_caches' do
      it 'delegates to both bundles' do
        exact.should_receive(:delete).once.with()
        partial.should_receive(:delete).once.with()
        
        category.clear_caches
      end
    end
    
    describe 'dump_caches' do
      before(:each) do
        exact.stub! :dump
        partial.stub! :dump
      end
      it 'should dump the exact index' do
        exact.should_receive(:dump).once.with

        category.dump_caches
      end
      it 'should dump the partial index' do
        partial.should_receive(:dump).once.with

        category.dump_caches
      end
    end
    
    describe 'generate_caches_from_memory' do
      it 'should delegate to partial' do
        partial.should_receive(:generate_caches_from_memory).once.with
        
        category.generate_caches_from_memory
      end
    end
    
    describe 'generate_partial' do
      it 'should return whatever the partial generation returns' do
        exact.stub! :index
        partial.stub! :generate_partial_from => :generation_returns

        category.generate_partial
      end
      it 'should use the exact index to generate the partial index' do
        exact_index = stub :exact_index
        exact.stub! :index => exact_index
        partial.should_receive(:generate_partial_from).once.with(exact_index)

        category.generate_partial
      end
    end

    describe 'generate_caches_from_source' do
      it 'should delegate to exact' do
        exact.should_receive(:generate_caches_from_source).once.with

        category.generate_caches_from_source
      end
    end

    describe 'generate_caches' do
      it 'should call multiple methods in order' do
        category.should_receive(:generate_caches_from_source).once.with().ordered
        category.should_receive(:generate_partial).once.with().ordered
        category.should_receive(:generate_caches_from_memory).once.with().ordered
        category.should_receive(:dump_caches).once.with().ordered
        category.should_receive(:timed_exclaim).once.ordered
        
        category.generate_caches
      end
    end
    
    describe 'source' do
      context 'with explicit source' do
        let(:category) { described_class.new(:some_category, @index, :source => :category_source) }
        it 'returns the right source' do
          category.source.should == :category_source
        end
      end
      context 'without explicit source' do
        let(:category) { described_class.new(:some_category, @index.tap{ |index| index.stub! :source => :index_source }) }
        it 'returns the right source' do
          category.source.should == :index_source
        end
      end
    end
    
    describe "cache" do
      before(:each) do
        category.stub! :generate_caches
      end
      it "prepares the cache directory" do
        category.should_receive(:prepare_index_directory).once.with
        
        category.cache!
      end
      it "tells the indexer to index" do
        category.should_receive(:generate_caches).once.with
        
        category.cache!
      end
    end
    describe "index" do
      before(:each) do
        @indexer = stub :indexer, :index => nil
        category.stub! :indexer => @indexer
      end
      it "prepares the cache directory" do
        category.should_receive(:prepare_index_directory).once.with
        
        category.index!
      end
      it "tells the indexer to index" do
        @indexer.should_receive(:index).once.with
        
        category.index!
      end
    end
    describe "source" do
      context "without source" do
        it "has no problem with that" do
          lambda { described_class.new :some_name, @index }.should_not raise_error
        end
      end
    end
  end
  
end