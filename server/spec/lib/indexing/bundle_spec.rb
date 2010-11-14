require 'spec_helper'

describe Indexing::Bundle do

  before(:each) do
    @index         = stub :index, :name => :some_index
    @category      = stub :category, :name => :some_category
    @configuration = Configuration::Index.new @index, @category
    
    @partial     = stub :partial
    @weights     = stub :weights
    @similarity  = stub :similarity
    @index       = Indexing::Bundle.new :some_name, @configuration, @similarity, @partial, @weights
  end

  describe 'identifier' do
    it 'should return a specific identifier' do
      @index.identifier.should == 'some_index some_category (some_name)'
    end
  end
  
  describe 'initialize_index_for' do
    context 'token not yet assigned' do
      before(:each) do
        @index.stub! :index => {}
      end
      it 'should assign it an empty array' do
        @index.initialize_index_for :some_token

        @index.index[:some_token].should == []
      end
    end
    context 'token already assigned' do
      before(:each) do
        @index.stub! :index => { :some_token => :already_assigned }
      end
      it 'should not assign it anymore' do
        @index.initialize_index_for :some_token

        @index.index[:some_token].should == :already_assigned
      end
    end
  end
  
  # TODO
  #
  # describe 'retrieve' do
  #   it 'should call the other methods correctly' do
  #     results = stub :results
  #     @index.stub! :execute_query => results
  #     @index.should_receive(:extract).once.with results
  #     
  #     @index.retrieve
  #   end
  # end

  describe 'load_from_index_file' do
    it 'should call two methods in order' do
      @index.should_receive(:load_from_index_generation_message).once.ordered
      @index.should_receive(:clear).once.ordered
      @index.should_receive(:retrieve).once.ordered

      @index.load_from_index_file
    end
  end

  describe 'generate_derived' do
    it 'should call two methods in order' do
      @index.should_receive(:generate_weights).once.ordered
      @index.should_receive(:generate_similarity).once.ordered

      @index.generate_derived
    end
  end

  describe 'generate_caches_from_memory' do
    it 'should call two methods in order' do
      @index.should_receive(:cache_from_memory_generation_message).once.ordered
      @index.should_receive(:generate_derived).once.ordered

      @index.generate_caches_from_memory
    end
  end

  describe 'generate_caches_from_source' do
    it 'should call two methods in order' do
      @index.should_receive(:load_from_index_file).once.ordered
      @index.should_receive(:generate_caches_from_memory).once.ordered

      @index.generate_caches_from_source
    end
  end
  
  describe 'dump' do
    it 'should trigger dumps' do
      @index.should_receive(:dump_index).once.with
      @index.should_receive(:dump_similarity).once.with
      @index.should_receive(:dump_weights).once.with
      
      @index.dump
    end
  end

  describe 'raise_unless_cache_exists' do
    it "calls methods in order" do
      @index.should_receive(:raise_unless_index_exists).once.ordered
      @index.should_receive(:raise_unless_similarity_exists).once.ordered
      
      @index.raise_unless_cache_exists
    end
  end
  describe 'raise_unless_index_exists' do
    context 'partial strategy saved' do
      before(:each) do
        strategy = stub :strategy, :saved? => true
        @index.stub! :partial_strategy => strategy
      end
      it "calls the methods in order" do
        @index.should_receive(:warn_if_index_small).once.ordered
        @index.should_receive(:raise_unless_index_ok).once.ordered
        
        @index.raise_unless_index_exists
      end
    end
    context 'partial strategy not saved' do
      before(:each) do
        strategy = stub :strategy, :saved? => false
        @index.stub! :partial_strategy => strategy
      end
      it "calls nothing" do
        @index.should_receive(:warn_if_index_small).never
        @index.should_receive(:raise_unless_index_ok).never
        
        @index.raise_unless_index_exists
      end
    end
  end
  describe 'raise_unless_similarity_exists' do
    context 'similarity strategy saved' do
      before(:each) do
        strategy = stub :strategy, :saved? => true
        @index.stub! :similarity_strategy => strategy
      end
      it "calls the methods in order" do
        @index.should_receive(:warn_if_similarity_small).once.ordered
        @index.should_receive(:raise_unless_similarity_ok).once.ordered
        
        @index.raise_unless_similarity_exists
      end
    end
    context 'similarity strategy not saved' do
      before(:each) do
        strategy = stub :strategy, :saved? => false
        @index.stub! :similarity_strategy => strategy
      end
      it "calls nothing" do
        @index.should_receive(:warn_if_similarity_small).never
        @index.should_receive(:raise_unless_similarity_ok).never
        
        @index.raise_unless_similarity_exists
      end
    end
  end
  describe 'warn_if_similarity_small' do
    before(:each) do
      @files = @index.files
    end
    context "files similarity cache small" do
      before(:each) do
        @files.stub! :similarity_cache_small? => true
      end
      it "warns" do
        @index.should_receive(:warn_cache_small).once.with :similarity
        
        @index.warn_if_similarity_small
      end
    end
    context "files similarity cache not small" do
      before(:each) do
        @files.stub! :similarity_cache_small? => false
      end
      it "does not warn" do
        @index.should_receive(:warn_cache_small).never
        
        @index.warn_if_similarity_small
      end
    end
  end
  describe 'raise_unless_similarity_ok' do
    before(:each) do
      @files = @index.files
    end
    context "files similarity cache ok" do
      before(:each) do
        @files.stub! :similarity_cache_ok? => true
      end
      it "warns" do
        @index.should_receive(:raise_cache_missing).never
        
        @index.raise_unless_similarity_ok
      end
    end
    context "files similarity cache not ok" do
      before(:each) do
        @files.stub! :similarity_cache_ok? => false
      end
      it "does not warn" do
        @index.should_receive(:raise_cache_missing).once.with :similarity
        
        @index.raise_unless_similarity_ok
      end
    end
  end
  
  describe 'initialization' do
    it 'should initialize the index correctly' do
      @index.index.should == {}
    end
    it 'should initialize the weights index correctly' do
      @index.weights.should == {}
    end
    it 'should initialize the similarity index correctly' do
      @index.similarity.should == {}
    end
    it 'should initialize the partial strategy correctly' do
      @index.partial_strategy.should == @partial
    end
    it 'should initialize the weights strategy correctly' do
      @index.weights_strategy.should == @weights
    end
    it 'should initialize the similarity strategy correctly' do
      @index.similarity_strategy.should == @similarity
    end
  end

end