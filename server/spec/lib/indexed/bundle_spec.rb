require 'spec_helper'

describe Indexed::Bundle do

  before(:each) do
    @category     = stub :category, :name => :some_category
    @index        = stub :index, :name => :some_index
    @configuration = Configuration::Index.new @index, @category
    
    @similarity   = stub :similarity
    @bundle_class = Indexed::Bundle
    @bundle       = @bundle_class.new :some_name, @configuration, @similarity
  end

  describe 'identifier' do
    it 'should return a specific identifier' do
      @bundle.identifier.should == 'some_index some_category (some_name)'
    end
  end

  describe 'ids' do
    before(:each) do
      @bundle.instance_variable_set :@index, { :existing => :some_ids }
    end
    it 'should return an empty array if not found' do
      @bundle.ids(:non_existing).should == []
    end
    it 'should return the ids if found' do
      @bundle.ids(:existing).should == :some_ids
    end
  end

  describe 'weight' do
    before(:each) do
      @bundle.instance_variable_set :@weights, { :existing => :specific }
    end
    it 'should return nil' do
      @bundle.weight(:non_existing).should == nil
    end
    it 'should return the weight for the text' do
      @bundle.weight(:existing).should == :specific
    end
  end
  
  describe 'load' do
    it 'should trigger loads' do
      @bundle.should_receive(:load_index).once.with
      @bundle.should_receive(:load_weights).once.with
      @bundle.should_receive(:load_similarity).once.with
      @bundle.should_receive(:load_configuration).once.with
      
      @bundle.load
    end
  end
  describe "loading indexes" do
    before(:each) do
      @bundle.stub! :timed_exclaim
    end
    describe "load_index" do
      it "uses the right file" do
        Yajl::Parser.stub! :parse
        
        File.should_receive(:open).once.with 'spec/test_directory/index/test/some_index/some_category_some_name_index.json', 'r'
        
        @bundle.load_index
      end
    end
    describe "load_weights" do
      it "uses the right file" do
        Yajl::Parser.stub! :parse
        
        File.should_receive(:open).once.with 'spec/test_directory/index/test/some_index/some_category_some_name_weights.json', 'r'
        
        @bundle.load_weights
      end
    end
    describe "load_similarity" do
      it "uses the right file" do
        Marshal.stub! :load
        
        File.should_receive(:open).once.with 'spec/test_directory/index/test/some_index/some_category_some_name_similarity.dump', 'r:binary'
        
        @bundle.load_similarity
      end
    end
    describe "load_configuration" do
      it "uses the right file" do
        Yajl::Parser.stub! :parse
        
        File.should_receive(:open).once.with 'spec/test_directory/index/test/some_index/some_category_some_name_configuration.json', 'r'
        
        @bundle.load_configuration
      end
    end
  end
  
  describe 'initialization' do
    before(:each) do
      @category = stub :category, :name => :some_category
      @index    = stub :index, :name => :some_index
      @configuration = Configuration::Index.new @index, @category
      
      @bundle = @bundle_class.new :some_name, @configuration, :similarity
    end
    it 'should initialize the index correctly' do
      @bundle.index.should == {}
    end
    it 'should initialize the weights index correctly' do
      @bundle.weights.should == {}
    end
    it 'should initialize the similarity index correctly' do
      @bundle.similarity.should == {}
    end
    it 'should initialize the configuration correctly' do
      @bundle.configuration.should == {}
    end
    it 'should initialize the similarity strategy correctly' do
      @bundle.similarity_strategy.should == :similarity
    end
  end

end