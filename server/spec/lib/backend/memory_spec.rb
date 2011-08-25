require 'spec_helper'

describe Picky::Backends::Memory do

  before(:each) do
    index         = Picky::Indexes::Memory.new :some_index
    category      = Picky::Category.new :some_category, index
    
    # This is just wrong.
    #
    bundle        = Picky::Indexing::Bundle.new :some_bundle, category, described_class, nil, nil, nil
    @files         = described_class.new bundle
    
    @index         = @files.inverted
    @weights       = @files.weights
    @similarity    = @files.similarity
    @configuration = @files.configuration
  end
  
  describe "dump indexes" do
    before(:each) do
      @files.stub! :timed_exclaim
    end
    describe "dump_index" do
      it "uses the right file" do
        @index.should_receive(:dump).once.with :some_hash
        
        @files.dump_inverted :some_hash
      end
    end
    describe "dump_weights" do
      it "uses the right file" do
        @weights.should_receive(:dump).once.with :some_hash
        
        @files.dump_weights :some_hash
      end
    end
    describe "dump_similarity" do
      it "uses the right file" do
        @similarity.should_receive(:dump).once.with :some_hash
        
        @files.dump_similarity :some_hash
      end
    end
    describe "dump_configuration" do
      it "uses the right file" do
        @configuration.should_receive(:dump).once.with :some_hash
        
        @files.dump_configuration :some_hash
      end
    end
  end
  
  describe "loading indexes" do
    before(:each) do
      @files.stub! :timed_exclaim
    end
    describe "load_index" do
      it "uses the right file" do
        Yajl::Parser.stub! :parse
        
        File.should_receive(:open).once.with 'spec/test_directory/index/test/some_index/some_category_some_bundle_inverted.json', 'r'
        
        @files.load_inverted
      end
    end
    describe "load_weights" do
      it "uses the right file" do
        Yajl::Parser.stub! :parse
        
        File.should_receive(:open).once.with 'spec/test_directory/index/test/some_index/some_category_some_bundle_weights.json', 'r'
        
        @files.load_weights
      end
    end
    describe "load_similarity" do
      it "uses the right file" do
        Marshal.stub! :load
        
        File.should_receive(:open).once.with 'spec/test_directory/index/test/some_index/some_category_some_bundle_similarity.dump', 'r:binary'
        
        @files.load_similarity
      end
    end
    describe "load_configuration" do
      it "uses the right file" do
        Yajl::Parser.stub! :parse
        
        File.should_receive(:open).once.with 'spec/test_directory/index/test/some_index/some_category_some_bundle_configuration.json', 'r'
        
        @files.load_configuration
      end
    end
  end
  
  describe "dump indexes" do
    describe "index_cache_ok?" do
      it 'uses the right method' do
        @index.should_receive(:cache_ok?).once.with
        
        @files.inverted_cache_ok?
      end
    end
    describe "weights_cache_ok?" do
      it 'uses the right method' do
        @weights.should_receive(:cache_ok?).once.with
        
        @files.weights_cache_ok?
      end
    end
    describe "similarity_cache_ok?" do
      it 'uses the right method' do
        @similarity.should_receive(:cache_ok?).once.with
        
        @files.similarity_cache_ok?
      end
    end
  end
  
  describe 'dump indexes' do
    describe 'inverted_cache_small?' do
      it 'uses the right method' do
        @index.should_receive(:cache_small?).once.with
        
        @files.inverted_cache_small?
      end
    end
    describe 'weights_cache_small?' do
      it 'uses the right method' do
        @weights.should_receive(:cache_small?).once.with
        
        @files.weights_cache_small?
      end
    end
    describe 'similarity_cache_small?' do
      it 'uses the right method' do
        @similarity.should_receive(:cache_small?).once.with
        
        @files.similarity_cache_small?
      end
    end
  end
  
  describe 'backup' do
    it 'should call backup on all' do
      @index.should_receive(:backup).once.with
      @weights.should_receive(:backup).once.with
      @similarity.should_receive(:backup).once.with
      @configuration.should_receive(:backup).once.with
      
      @files.backup
    end
  end
  describe 'restore' do
    it 'should call delete on all' do
      @index.should_receive(:restore).once.with
      @weights.should_receive(:restore).once.with
      @similarity.should_receive(:restore).once.with
      @configuration.should_receive(:restore).once.with
      
      @files.restore
    end
  end
  describe 'delete' do
    it 'should call delete on all' do
      @index.should_receive(:delete).once.with
      @weights.should_receive(:delete).once.with
      @similarity.should_receive(:delete).once.with
      @configuration.should_receive(:delete).once.with
      
      @files.delete
    end
  end
  
  describe 'initialization' do
    it 'should initialize the name correctly' do
      @files.bundle.name.should == :some_bundle
    end
  end
  
  describe 'to_s' do
    it 'returns the right value' do
      bundle   = stub :bundle,
                      :index_path => 'index/path',
                      :prepared_index_path => 'prepared/index/path'
      
      described_class.new(bundle).to_s.should == "Picky::Backends::Memory(Picky::Backends::File::JSON(index/path.json), Picky::Backends::File::JSON(index/path.json), Picky::Backends::File::Marshal(index/path.dump), Picky::Backends::File::JSON(index/path.json))"
    end
  end

end