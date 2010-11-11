require 'spec_helper'

describe Indexed::Bundle do

  before(:each) do
    @category     = stub :category, :name => :some_category
    @index        = stub :index, :name => :some_index
    @similarity   = stub :similarity
    @bundle_class = Indexed::Bundle
    @bundle       = @bundle_class.new :some_name, @category, @index, @similarity
  end

  describe 'identifier' do
    it 'should return a specific identifier' do
      @bundle.identifier.should == 'some_index: some_name some_category'
    end
  end

  describe 'load_from_index_file' do
    it 'should call two methods in order' do
      @bundle.should_receive(:load_from_index_generation_message).once.ordered
      @bundle.should_receive(:clear).once.ordered
      @bundle.should_receive(:retrieve).once.ordered
      
      @bundle.load_from_index_file
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
      @bundle.should_receive(:load_similarity).once.with
      @bundle.should_receive(:load_weights).once.with
      
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
        
        File.should_receive(:open).once.with 'some/search/root/index/test/some_index/some_name_some_category_index.json', 'r'
        
        @bundle.load_index
      end
    end
    describe "load_similarity" do
      it "uses the right file" do
        Marshal.stub! :load
        
        File.should_receive(:open).once.with 'some/search/root/index/test/some_index/some_name_some_category_similarity.dump', 'r:binary'
        
        @bundle.load_similarity
      end
    end
    describe "load_weights" do
      it "uses the right file" do
        Yajl::Parser.stub! :parse
        
        File.should_receive(:open).once.with 'some/search/root/index/test/some_index/some_name_some_category_weights.json', 'r'
        
        @bundle.load_weights
      end
    end
  end
  
  describe 'initialization' do
    before(:each) do
      @category = stub :category, :name => :some_category
      @index    = stub :index, :name => :some_index
      
      @bundle = @bundle_class.new :some_name, @category, @index, :similarity
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
    it 'should initialize the similarity strategy correctly' do
      @bundle.similarity_strategy.should == :similarity
    end
  end

end