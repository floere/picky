require 'spec_helper'

describe Picky::Indexed::Bundle do

  before(:each) do
    @index        = Picky::Index.new :some_index
    @category     = Picky::Category.new :some_category, @index
    
    @similarity   = stub :similarity
    @bundle       = described_class.new :some_name, @category, Picky::Backends::Memory, @similarity
  end
  
  describe 'to_s' do
    it 'does something' do
      @bundle.to_s.should == "Picky::Indexed::Bundle(test:some_index:some_category:some_name)"
    end
  end
  
  describe 'clear_index' do
    before(:each) do
      @bundle.instance_variable_set :@inverted, { :a => [] }
    end
    it 'has not cleared the inverted index' do
      @bundle.inverted.should == { :a => [] }
    end
    it 'clears the inverted index' do
      @bundle.clear_inverted
      
      @bundle.inverted.should be_empty
    end
  end
  describe 'clear_weights' do
    before(:each) do
      @bundle.instance_variable_set :@weights, { :a => 1.0 }
    end
    it 'has not cleared the weights' do
      @bundle.weights.should == { :a => 1.0 }
    end
    it 'clears the weights' do
      @bundle.clear_weights
      
      @bundle.weights.should be_empty
    end
  end
  describe 'clear_similarity' do
    before(:each) do
      @bundle.instance_variable_set :@similarity, { :a => :aa }
    end
    it 'has not cleared the similarity index' do
      @bundle.similarity.should == { :a => :aa }
    end
    it 'clears the similarity index' do
      @bundle.clear_similarity
      
      @bundle.similarity.should be_empty
    end
  end
  describe 'clear_configuration' do
    before(:each) do
      @bundle.instance_variable_set :@configuration, { :a => 'value' }
    end
    it 'has not cleared the similarity index' do
      @bundle.configuration.should == { :a => 'value' }
    end
    it 'clears the similarity index' do
      @bundle.clear_configuration
      
      @bundle.configuration.should be_empty
    end
  end

  describe 'identifier' do
    it 'should return a specific identifier' do
      @bundle.identifier.should == 'test:some_index:some_category:some_name'
    end
  end

  describe 'ids' do
    before(:each) do
      @bundle.instance_variable_set :@inverted, { :existing => :some_ids }
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
      @bundle.should_receive(:load_inverted).once.with
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
        
        File.should_receive(:open).once.with 'spec/test_directory/index/test/some_index/some_category_some_name_inverted.json', 'r'
        
        @bundle.load_inverted
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
      @index    = Picky::Index.new :some_index
      @category = Picky::Category.new :some_category, @index
      
      @bundle = described_class.new :some_name, @category, Picky::Backends::Memory, :similarity
    end
    it 'should initialize the index correctly' do
      @bundle.inverted.should == {}
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