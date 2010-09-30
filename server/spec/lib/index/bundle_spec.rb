require 'spec_helper'

describe Index::Bundle do

  before(:each) do
    @category    = stub :category, :name => :some_category
    @type        = stub :type, :name => :some_type
    @partial     = stub :partial
    @weights     = stub :weights
    @similarity  = stub :similarity
    @index_class = Index::Bundle
    @index       = @index_class.new :some_name, @category, @type, @partial, @weights, @similarity
  end

  describe 'identifier' do
    it 'should return a specific identifier' do
      @index.identifier.should == 'some_name:some_type:some_category'
    end
  end

  describe 'create_directory' do
    it 'should use makedirs to create the necessary directory structure' do
      FileUtils.should_receive(:mkdir_p).once.with 'some/search/root/index/test/some_type'

      @index.create_directory
    end
  end

  describe 'cache_directory' do
    it 'should be correct' do
      @index.cache_directory.should == 'some/search/root/index/test/some_type'
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

  describe 'generate_caches_from_db' do
    it 'should call two methods in order' do
      @index.should_receive(:cache_from_db_generation_message).once.ordered
      @index.should_receive(:load_from_index_file).once.ordered
      @index.should_receive(:generate_caches_from_memory).once.ordered

      @index.generate_caches_from_db
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

  describe 'raise_unless_cache_exists' do
    before(:each) do
      @index.stub! :cache_small? => false
    end
    context 'weights cache missing' do
      before(:each) do
        @index.stub! :cache_ok? => true
        @index.stub! :weights_cache_path => 'weights_cache_path'
        @index.should_receive(:cache_ok?).any_number_of_times.with('weights_cache_path').and_return false
      end
      it 'should raise' do
        lambda do
          @index.raise_unless_cache_exists
        end.should raise_error("weights cache for some_name:some_type:some_category missing.")
      end
    end
    context 'similarity cache missing' do
      before(:each) do
        @index.stub! :cache_ok? => true
        @index.stub! :similarity_cache_path => 'similarity_cache_path'
        @index.should_receive(:cache_ok?).any_number_of_times.with('similarity_cache_path').and_return false
      end
      it 'should raise' do
        lambda do
          @index.raise_unless_cache_exists
        end.should raise_error("similarity cache for some_name:some_type:some_category missing.")
      end
    end
    context 'index cache missing' do
      before(:each) do
        @index.stub! :cache_ok? => true
        @index.stub! :index_cache_path => 'index_cache_path'
        @index.should_receive(:cache_ok?).any_number_of_times.with('index_cache_path').and_return false
      end
      it 'should raise' do
        lambda do
          @index.raise_unless_cache_exists
        end.should raise_error("index cache for some_name:some_type:some_category missing.")
      end
    end
    context 'all ok' do
      before(:each) do
        @index.stub! :cache_ok? => true
      end
      it 'should not raise' do
        lambda { @index.raise_unless_cache_exists }.should_not raise_error
      end
    end
  end

  describe 'delete_all' do
    it 'should call delete with all paths' do
      @index.should_receive(:delete).once.with @index.index_cache_path
      @index.should_receive(:delete).once.with @index.similarity_cache_path
      @index.should_receive(:delete).once.with @index.weights_cache_path

      @index.delete_all
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

  describe 'dump' do
    it 'should trigger dumps' do
      @index.should_receive(:dump_index).once.with
      @index.should_receive(:dump_similarity).once.with
      @index.should_receive(:dump_weights).once.with

      @index.dump
    end
  end

  describe 'weights_cache_path' do
    it 'should return the correct file name' do
      @index.weights_cache_path.should == 'some/search/root/index/test/some_type/some_name_some_category_weights.dump'
    end
  end
  describe 'similarity_cache_path' do
    it 'should return the correct file name' do
      @index.similarity_cache_path.should == 'some/search/root/index/test/some_type/some_name_some_category_similarity.dump'
    end
  end
  describe 'index_cache_path' do
    it 'should return the correct file name' do
      @index.index_cache_path.should == 'some/search/root/index/test/some_type/some_name_some_category_index.dump'
    end
  end

  describe 'initialization' do
    before(:each) do
      @index = @index_class.new :some_name, :some_category, :some_type, :partial, :weights, :similarity
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
    it 'should initialize the name correctly' do
      @index.name.should == :some_name
    end
    it 'should initialize the name correctly' do
      @index.category.should == :some_category
    end
    it 'should initialize the name correctly' do
      @index.type.should == :some_type
    end
    it 'should initialize the partial strategy correctly' do
      @index.partial_strategy.should == :partial
    end
    it 'should initialize the weights strategy correctly' do
      @index.weights_strategy.should == :weights
    end
    it 'should initialize the similarity strategy correctly' do
      @index.similarity_strategy.should == :similarity
    end
  end

end