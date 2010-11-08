require 'spec_helper'

describe Index::Bundle do

  before(:each) do
    @category    = stub :category, :name => :some_category
    @type        = stub :type, :name => :some_type
    @similarity  = stub :similarity
    @index_class = Index::Bundle
    @index       = @index_class.new :some_name, @category, @type, @similarity
  end

  describe 'identifier' do
    it 'should return a specific identifier' do
      @index.identifier.should == 'some_name: some_type some_category'
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

  describe 'ids' do
    before(:each) do
      @index.instance_variable_set :@index, { :existing => :some_ids }
    end
    it 'should return an empty array if not found' do
      @index.ids(:non_existing).should == []
    end
    it 'should return the ids if found' do
      @index.ids(:existing).should == :some_ids
    end
  end

  describe 'weight' do
    before(:each) do
      @index.instance_variable_set :@weights, { :existing => :specific }
    end
    it 'should return nil' do
      @index.weight(:non_existing).should == nil
    end
    it 'should return the weight for the text' do
      @index.weight(:existing).should == :specific
    end
  end
  
  describe 'load' do
    it 'should trigger loads' do
      @index.should_receive(:load_index).once.with
      @index.should_receive(:load_similarity).once.with
      @index.should_receive(:load_weights).once.with

      @index.load
    end
  end
  describe "loading indexes" do
    before(:each) do
      @index.stub! :timed_exclaim
    end
    describe "load_index" do
      it "uses the right file" do
        Yajl::Parser.stub! :parse
        
        File.should_receive(:open).once.with 'some/search/root/index/test/some_type/some_name_some_category_index.json', 'r'
        
        @index.load_index
      end
    end
    describe "load_similarity" do
      it "uses the right file" do
        Marshal.stub! :load
        
        File.should_receive(:open).once.with 'some/search/root/index/test/some_type/some_name_some_category_similarity.dump', 'r:binary'
        
        @index.load_similarity
      end
    end
    describe "load_weights" do
      it "uses the right file" do
        Yajl::Parser.stub! :parse
        
        File.should_receive(:open).once.with 'some/search/root/index/test/some_type/some_name_some_category_weights.json', 'r'
        
        @index.load_weights
      end
    end
  end
  
  describe 'initialization' do
    before(:each) do
      @category = stub :category, :name => :some_category
      @type     = stub :type, :name => :some_type
      
      @index = @index_class.new :some_name, @category, @type, :similarity
    end
    it 'should initialize the index correctly' do
      @index.index.should == {}
    end
    it 'should initialize the weights index correctly' do
      @index.weights.should == {}
    end
    it 'should initialize the similarity index correctly' do
      @index.similarity.should == {}
    end
    it 'should initialize the similarity strategy correctly' do
      @index.similarity_strategy.should == :similarity
    end
  end

end