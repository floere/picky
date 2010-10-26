require 'spec_helper'

describe Index::Files do

  before(:each) do
    @files_class = Index::Files
    @files       = @files_class.new :some_name, :some_category, :some_type
    
    @index       = @files.index
    @similarity  = @files.similarity
    @weights     = @files.weights
  end

  describe 'create_directory' do
    it 'should use makedirs to create the necessary directory structure' do
      FileUtils.should_receive(:mkdir_p).once.with 'some/search/root/index/test/some_type'

      @files.create_directory
    end
  end

  describe 'cache_directory' do
    it 'should be correct' do
      @files.cache_directory.should == 'some/search/root/index/test/some_type'
    end
  end
  
  # TODO
  #
  # describe 'retrieve' do
  #   it 'should call the other methods correctly' do
  #     results = stub :results
  #     @files.stub! :execute_query => results
  #     @files.should_receive(:extract).once.with results
  #     
  #     @files.retrieve
  #   end
  # end

  describe 'delete_all' do
    it 'should call delete with all paths' do
      @index.should_receive(:delete).once.with
      @similarity.should_receive(:delete).once.with
      @weights.should_receive(:delete).once.with
      
      @files.delete
    end
  end
  
  describe "loading indexes" do
    before(:each) do
      @files.stub! :timed_exclaim
    end
    describe "load_index" do
      it "uses the right file" do
        Yajl::Parser.stub! :parse
        
        File.should_receive(:open).once.with 'some/search/root/index/test/some_type/some_name_some_category_index.json', 'r'
        
        @files.load_index
      end
    end
    describe "load_similarity" do
      it "uses the right file" do
        Marshal.stub! :load
        
        File.should_receive(:open).once.with 'some/search/root/index/test/some_type/some_name_some_category_similarity.dump', 'r:binary'
        
        @files.load_similarity
      end
    end
    describe "load_weights" do
      it "uses the right file" do
        Yajl::Parser.stub! :parse
        
        File.should_receive(:open).once.with 'some/search/root/index/test/some_type/some_name_some_category_weights.json', 'r'
        
        @files.load_weights
      end
    end
  end
  
  describe 'initialization' do
    before(:each) do
      @files = @files_class.new :some_name, :some_category, :some_type
    end
    it 'should initialize the name correctly' do
      @files.bundle_name.should == :some_name
    end
    it 'should initialize the name correctly' do
      @files.category_name.should == :some_category
    end
    it 'should initialize the name correctly' do
      @files.type_name.should == :some_type
    end
  end

end