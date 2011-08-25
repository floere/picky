require 'spec_helper'

describe Picky::Backends::Memory do

  before(:each) do
    @backend = described_class.new
    @backend.configure(Class.new do
      def index_path ending
        "spec/test_directory/index/test/some_index/some_category_some_bundle_#{ending}"
      end
    end.new)
    @backend.stub! :timed_exclaim
  end
  
  describe "loading indexes" do
    describe "load_index" do
      it "uses the right file" do
        Yajl::Parser.stub! :parse
        
        File.should_receive(:open).once.with 'spec/test_directory/index/test/some_index/some_category_some_bundle_inverted.json', 'r'
        
        @backend.load_inverted
      end
    end
    describe "load_weights" do
      it "uses the right file" do
        Yajl::Parser.stub! :parse
        
        File.should_receive(:open).once.with 'spec/test_directory/index/test/some_index/some_category_some_bundle_weights.json', 'r'
        
        @backend.load_weights
      end
    end
    describe "load_similarity" do
      it "uses the right file" do
        Marshal.stub! :load
        
        File.should_receive(:open).once.with 'spec/test_directory/index/test/some_index/some_category_some_bundle_similarity.dump', 'r:binary'
        
        @backend.load_similarity
      end
    end
    describe "load_configuration" do
      it "uses the right file" do
        Yajl::Parser.stub! :parse
        
        File.should_receive(:open).once.with 'spec/test_directory/index/test/some_index/some_category_some_bundle_configuration.json', 'r'
        
        @backend.load_configuration
      end
    end
  end
  
  describe "ids" do
    before(:each) do
      @combination1 = stub :combination1
      @combination2 = stub :combination2
      @combination3 = stub :combination3
      @combinations = [@combination1, @combination2, @combination3]
    end
    it "should intersect correctly" do
      @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
      @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      @backend.ids(@combinations, :any, :thing).should == (1..10).to_a
    end
    it "should intersect symbol_keys correctly" do
      @combination1.should_receive(:ids).once.with.and_return (:'00001'..:'10000').to_a
      @combination2.should_receive(:ids).once.with.and_return (:'00001'..:'00100').to_a
      @combination3.should_receive(:ids).once.with.and_return (:'00001'..:'00010').to_a

      @backend.ids(@combinations, :any, :thing).should == (:'00001'..:'0010').to_a
    end
    it "should intersect correctly when intermediate intersect result is empty" do
      @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
      @combination2.should_receive(:ids).once.with.and_return (11..100).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      @backend.ids(@combinations, :any, :thing).should == []
    end
    it "should be fast" do
      @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
      @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      performance_of { @backend.ids(@combinations, :any, :thing) }.should < 0.004
    end
    it "should be fast" do
      @combination1.should_receive(:ids).once.with.and_return (1..1000).to_a
      @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      performance_of { @backend.ids(@combinations, :any, :thing) }.should < 0.00015
    end
    it "should be fast" do
      @combination1.should_receive(:ids).once.with.and_return (1..1000).to_a
      @combination2.should_receive(:ids).once.with.and_return (901..1000).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      performance_of { @backend.ids(@combinations, :any, :thing) }.should < 0.0001
    end
  end
  
  describe "dump indexes" do
    before(:each) do
      @backend.stub! :timed_exclaim
    end
    describe "dump_index" do
      it "uses the right file" do
        @backend.inverted.should_receive(:dump).once.with :some_hash
        
        @backend.dump_inverted :some_hash
      end
    end
    describe "dump_weights" do
      it "uses the right file" do
        @backend.weights.should_receive(:dump).once.with :some_hash
        
        @backend.dump_weights :some_hash
      end
    end
    describe "dump_similarity" do
      it "uses the right file" do
        @backend.similarity.should_receive(:dump).once.with :some_hash
        
        @backend.dump_similarity :some_hash
      end
    end
    describe "dump_configuration" do
      it "uses the right file" do
        @backend.configuration.should_receive(:dump).once.with :some_hash
        
        @backend.dump_configuration :some_hash
      end
    end
  end
  
  describe "dump indexes" do
    describe "index_cache_ok?" do
      it 'uses the right method' do
        @backend.inverted.should_receive(:cache_ok?).once.with
        
        @backend.inverted_cache_ok?
      end
    end
    describe "weights_cache_ok?" do
      it 'uses the right method' do
        @backend.weights.should_receive(:cache_ok?).once.with
        
        @backend.weights_cache_ok?
      end
    end
    describe "similarity_cache_ok?" do
      it 'uses the right method' do
        @backend.similarity.should_receive(:cache_ok?).once.with
        
        @backend.similarity_cache_ok?
      end
    end
  end
  
  describe 'dump indexes' do
    describe 'inverted_cache_small?' do
      it 'uses the right method' do
        @backend.inverted.should_receive(:cache_small?).once.with
        
        @backend.inverted_cache_small?
      end
    end
    describe 'weights_cache_small?' do
      it 'uses the right method' do
        @backend.weights.should_receive(:cache_small?).once.with
        
        @backend.weights_cache_small?
      end
    end
    describe 'similarity_cache_small?' do
      it 'uses the right method' do
        @backend.similarity.should_receive(:cache_small?).once.with
        
        @backend.similarity_cache_small?
      end
    end
  end
  
  describe 'backup' do
    it 'should call backup on all' do
      @backend.inverted.should_receive(:backup).once.with
      @backend.weights.should_receive(:backup).once.with
      @backend.similarity.should_receive(:backup).once.with
      @backend.configuration.should_receive(:backup).once.with
      
      @backend.backup
    end
  end
  describe 'restore' do
    it 'should call delete on all' do
      @backend.inverted.should_receive(:restore).once.with
      @backend.weights.should_receive(:restore).once.with
      @backend.similarity.should_receive(:restore).once.with
      @backend.configuration.should_receive(:restore).once.with
      
      @backend.restore
    end
  end
  describe 'delete' do
    it 'should call delete on all' do
      @backend.inverted.should_receive(:delete).once.with
      @backend.weights.should_receive(:delete).once.with
      @backend.similarity.should_receive(:delete).once.with
      @backend.configuration.should_receive(:delete).once.with
      
      @backend.delete
    end
  end
  
  # describe 'to_s' do
  #   it 'returns the right value' do
  #     bundle = stub :bundle,
  #                   :index_path => 'index/path',
  #                   :prepared_index_path => 'prepared/index/path'
  #     
  #     memory = described_class.new
  #     memory.to_s.should == "Picky::Backends::Memory(Picky::Backends::File::JSON(index/path.json), Picky::Backends::File::JSON(index/path.json), Picky::Backends::File::Marshal(index/path.dump), Picky::Backends::File::JSON(index/path.json))"
  #   end
  # end

end