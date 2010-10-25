require 'spec_helper'

describe Index::BundleChecker do
  
  before(:each) do
    @category    = stub :category, :name => :some_category
    @type        = stub :type, :name => :some_type
    @partial     = stub :partial
    @weights     = stub :weights
    @similarity  = stub :similarity
    @index_class = Index::Bundle
    @index       = @index_class.new :some_name, @category, @type, @partial, @weights, @similarity
    
    @checker = @index.checker
  end
  
  describe 'raise_unless_cache_exists' do
    before(:each) do
      @checker.stub! :cache_small? => false
    end
    context 'weights cache missing' do
      before(:each) do
        @checker.stub! :cache_ok? => true
        @index.stub! :weights_cache_path => 'weights_cache_path'
        @checker.should_receive(:cache_ok?).any_number_of_times.with('weights_cache_path').and_return false
      end
      it 'should raise' do
        lambda do
          @checker.raise_unless_cache_exists
        end.should raise_error("weights cache for some_name: some_type some_category missing.")
      end
    end
    context 'similarity cache missing' do
      before(:each) do
        @checker.stub! :cache_ok? => true
        @index.stub! :similarity_cache_path => 'similarity_cache_path'
        @checker.should_receive(:cache_ok?).any_number_of_times.with('similarity_cache_path').and_return false
      end
      it 'should raise' do
        lambda do
          @checker.raise_unless_cache_exists
        end.should raise_error("similarity cache for some_name: some_type some_category missing.")
      end
    end
    context 'index cache missing' do
      before(:each) do
        @checker.stub! :cache_ok? => true
        @index.stub! :index_cache_path => 'index_cache_path'
        @checker.should_receive(:cache_ok?).any_number_of_times.with('index_cache_path').and_return false
      end
      it 'should raise' do
        lambda do
          @checker.raise_unless_cache_exists
        end.should raise_error("index cache for some_name: some_type some_category missing.")
      end
    end
    context 'all ok' do
      before(:each) do
        @checker.stub! :cache_ok? => true
      end
      it 'should not raise' do
        lambda { @checker.raise_unless_cache_exists }.should_not raise_error
      end
    end
  end
  
end