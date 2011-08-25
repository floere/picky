require 'spec_helper'

describe Picky::Indexing::Bundle do

  before(:each) do
    @index    = Picky::Index.new :some_index
    @category = Picky::Category.new :some_category, @index
    @similarity = Picky::Similarity::DoubleMetaphone.new 3
    @bundle = described_class.new :some_name, @category, Picky::Backends::Memory.new, :some_weights, :some_partial, @similarity
  end
  let(:index) { described_class.new :some_name, @category, Picky::Backends::Memory.new, @weights, @partial, @similarity }
  
  describe 'identifier' do
    it 'is correct' do
      @bundle.identifier.should == 'test:some_index:some_category:some_name'
    end
  end
  
  describe 'similar' do
    before(:each) do
      @bundle.similarity = @similarity.generate_from( :dragon => [1,2,3], :dargon => [4,5,6] )
    end
    it 'returns the right similars (not itself)' do
      @bundle.similar(:dragon).should == [:dargon]
    end
    it 'returns the right similars' do
      @bundle.similar(:trkn).should == [:dragon, :dargon]
    end
    it 'performs' do
      performance_of { @bundle.similar(:dragon) }.should < 0.000075
    end
    it 'performs' do
      performance_of { @bundle.similar(:trkn) }.should < 0.00006
    end
  end
  
  describe 'raise_cache_missing' do
    it 'does something' do
      expect {
        index.raise_cache_missing :similarity
      }.to raise_error("Error: The similarity cache for test:some_index:some_category:some_name is missing.")
    end
  end
  
  describe 'warn_cache_small' do
    it 'warns the user' do
      index.should_receive(:warn).once.with "Warning: similarity cache for test:some_index:some_category:some_name smaller than 16 bytes."
      
      index.warn_cache_small :similarity
    end
  end
  
  describe 'identifier' do
    it 'should return a specific identifier' do
      index.identifier.should == 'test:some_index:some_category:some_name'
    end
  end
  
  describe 'initialize_index_for' do
    context 'token not yet assigned' do
      before(:each) do
        index.stub! :index => {}
      end
      it 'should assign it an empty array' do
        index.initialize_inverted_index_for :some_token

        index.inverted[:some_token].should == []
      end
    end
    context 'token already assigned' do
      before(:each) do
        index.stub! :index => { :some_token => :already_assigned }
      end
      it 'should not assign it anymore' do
        index.initialize_inverted_index_for :some_token

        index.index[:some_token].should == :already_assigned
      end
    end
  end
  
  describe 'retrieve' do
    before(:each) do
      prepared = stub :prepared
      prepared.should_receive(:retrieve).once.and_yield '  1234', :some_token
      index.stub! :prepared => prepared
      
      @ary = stub :ary
      inverted = stub :inverted, :[] => @ary
      index.stub! :inverted => inverted
    end
    context 'id key format' do
      before(:each) do
        @category.stub! :key_format => :to_i
      end
      it 'should call the other methods correctly' do
        @ary.should_receive(:<<).once.with 1234
        
        index.retrieve
      end
    end
    context 'other key format' do
      before(:each) do
        @category.stub! :key_format => :strip
      end
      it 'should call the other methods correctly' do
        @ary.should_receive(:<<).once.with '1234'
        
        index.retrieve
      end
    end
    context 'no key format - default' do
      before(:each) do
        @category.stub! :key_format => nil
      end
      it 'should call the other methods correctly' do
        @ary.should_receive(:<<).once.with 1234
        
        index.retrieve
      end
    end
  end

  describe 'load_from_index_file' do
    it 'should call two methods in order' do
      index.should_receive(:load_from_prepared_index_generation_message).once.ordered
      index.should_receive(:clear).once.ordered
      index.should_receive(:retrieve).once.ordered

      index.load_from_prepared_index_file
    end
  end

  describe 'generate_derived' do
    it 'should call two methods in order' do
      index.should_receive(:generate_weights).once.ordered
      index.should_receive(:generate_similarity).once.ordered

      index.generate_derived
    end
  end

  describe 'generate_caches_from_memory' do
    it 'should call two methods in order' do
      index.should_receive(:cache_from_memory_generation_message).once.ordered
      index.should_receive(:generate_derived).once.ordered

      index.generate_caches_from_memory
    end
  end

  describe 'generate_caches_from_source' do
    it 'should call two methods in order' do
      index.should_receive(:load_from_prepared_index_file).once.ordered
      index.should_receive(:generate_caches_from_memory).once.ordered

      index.generate_caches_from_source
    end
  end
  
  describe 'dump' do
    it 'should trigger dumps' do
      index.stub! :timed_exclaim
      
      index.should_receive(:dump_inverted).once.with
      index.should_receive(:dump_weights).once.with
      index.should_receive(:dump_similarity).once.with
      index.should_receive(:dump_configuration).once.with
      
      index.dump
    end
  end

  describe 'raise_unless_cache_exists' do
    it "calls methods in order" do
      index.should_receive(:raise_unless_index_exists).once.ordered
      index.should_receive(:raise_unless_similarity_exists).once.ordered
      
      index.raise_unless_cache_exists
    end
  end
  describe 'raise_unless_index_exists' do
    context 'partial strategy saved' do
      before(:each) do
        strategy = stub :strategy, :saved? => true
        index.stub! :partial_strategy => strategy
      end
      it "calls the methods in order" do
        index.should_receive(:warn_if_index_small).once.ordered
        index.should_receive(:raise_unless_index_ok).once.ordered
        
        index.raise_unless_index_exists
      end
    end
    context 'partial strategy not saved' do
      before(:each) do
        strategy = stub :strategy, :saved? => false
        index.stub! :partial_strategy => strategy
      end
      it "calls nothing" do
        index.should_receive(:warn_if_index_small).never
        index.should_receive(:raise_unless_index_ok).never
        
        index.raise_unless_index_exists
      end
    end
  end
  describe 'raise_unless_similarity_exists' do
    context 'similarity strategy saved' do
      before(:each) do
        strategy = stub :strategy, :saved? => true
        index.stub! :similarity_strategy => strategy
      end
      it "calls the methods in order" do
        index.should_receive(:warn_if_similarity_small).once.ordered
        index.should_receive(:raise_unless_similarity_ok).once.ordered
        
        index.raise_unless_similarity_exists
      end
    end
    context 'similarity strategy not saved' do
      before(:each) do
        strategy = stub :strategy, :saved? => false
        index.stub! :similarity_strategy => strategy
      end
      it "calls nothing" do
        index.should_receive(:warn_if_similarity_small).never
        index.should_receive(:raise_unless_similarity_ok).never
        
        index.raise_unless_similarity_exists
      end
    end
  end
  describe 'warn_if_similarity_small' do
    before(:each) do
      @backend = index.backend
    end
    context "files similarity cache small" do
      before(:each) do
        @backend.stub! :similarity_cache_small? => true
      end
      it "warns" do
        index.should_receive(:warn_cache_small).once.with :similarity
        
        index.warn_if_similarity_small
      end
    end
    context "files similarity cache not small" do
      before(:each) do
        @backend.stub! :similarity_cache_small? => false
      end
      it "does not warn" do
        index.should_receive(:warn_cache_small).never
        
        index.warn_if_similarity_small
      end
    end
  end
  describe 'raise_unless_similarity_ok' do
    before(:each) do
      @backend = index.backend
    end
    context "files similarity cache ok" do
      before(:each) do
        @backend.stub! :similarity_cache_ok? => true
      end
      it "warns" do
        index.should_receive(:raise_cache_missing).never
        
        index.raise_unless_similarity_ok
      end
    end
    context "files similarity cache not ok" do
      before(:each) do
        @backend.stub! :similarity_cache_ok? => false
      end
      it "does not warn" do
        index.should_receive(:raise_cache_missing).once.with :similarity
        
        index.raise_unless_similarity_ok
      end
    end
  end
  
  describe 'initialization' do
    it 'should initialize the index correctly' do
      index.inverted.should == {}
    end
    it 'should initialize the weights index correctly' do
      index.weights.should == {}
    end
    it 'should initialize the similarity index correctly' do
      index.similarity.should == {}
    end
    it 'should initialize the configuration correctly' do
      index.configuration.should == {}
    end
    it 'should initialize the partial strategy correctly' do
      index.partial_strategy.should == @partial
    end
    it 'should initialize the weights strategy correctly' do
      index.weights_strategy.should == @weights
    end
    it 'should initialize the similarity strategy correctly' do
      index.similarity_strategy.should == @similarity
    end
  end
  
end