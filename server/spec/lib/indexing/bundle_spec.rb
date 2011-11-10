require 'spec_helper'

describe Picky::Bundle do

  before(:each) do
    @index    = Picky::Index.new :some_index
    @category = Picky::Category.new :some_category, @index
    @similarity = Picky::Similarity::DoubleMetaphone.new 3
  end
  let(:bundle) { described_class.new :some_name, @category, Picky::Backends::Memory.new, :some_weights, :some_partial, @similarity }

  describe 'identifier' do
    it 'is correct' do
      bundle.identifier.should == 'test:some_index:some_category:some_name'
    end
  end

  describe 'similar' do
    before(:each) do
      bundle.similarity = @similarity.generate_from( :dragon => [1,2,3], :dargon => [4,5,6] )
    end
    it 'returns the right similars (not itself)' do
      bundle.similar(:dragon).should == [:dargon]
    end
    it 'returns the right similars' do
      bundle.similar(:trkn).should == [:dragon, :dargon]
    end
    it 'performs' do
      performance_of { bundle.similar(:dragon) }.should < 0.000075
    end
    it 'performs' do
      performance_of { bundle.similar(:trkn) }.should < 0.00006
    end
  end

  describe 'raise_cache_missing' do
    it 'does something' do
      expect {
        bundle.raise_cache_missing :similarity
      }.to raise_error("Error: The similarity cache for test:some_index:some_category:some_name is missing.")
    end
  end

  describe 'warn_cache_small' do
    it 'warns the user' do
      bundle.should_receive(:warn).once.with "Warning: similarity cache for test:some_index:some_category:some_name smaller than 16 bytes."

      bundle.warn_cache_small :similarity
    end
  end

  describe 'identifier' do
    it 'should return a specific identifier' do
      bundle.identifier.should == 'test:some_index:some_category:some_name'
    end
  end

  describe 'initialize_index_for' do
    context 'token not yet assigned' do
      before(:each) do
        bundle.stub! :index => {}
      end
      it 'should assign it an empty array' do
        bundle.initialize_inverted_index_for :some_token

        bundle.inverted[:some_token].should == []
      end
    end
    context 'token already assigned' do
      before(:each) do
        bundle.stub! :index => { :some_token => :already_assigned }
      end
      it 'should not assign it anymore' do
        bundle.initialize_inverted_index_for :some_token

        bundle.index[:some_token].should == :already_assigned
      end
    end
  end

  describe 'retrieve' do
    before(:each) do
      @ary = []

      prepared = stub :prepared
      prepared.should_receive(:retrieve).once.and_yield(' 1',     :some_token)
                                             .and_yield('1 ',     :some_token)
                                             .and_yield('1',      :some_token)
                                             .and_yield('    2',  :some_token)
                                             .and_yield('3',      :some_token)
                                             .and_yield('  3  ',  :some_token)
                                             .and_yield('  1234', :some_token)

      bundle.stub! :prepared => prepared

      bundle.stub! :inverted => { :some_token => @ary }
    end
    context 'uniqueness' do
      before(:each) do
        @category.stub! :key_format => :to_i
      end
      it 'is correct' do
        bundle.retrieve

        bundle.inverted[:some_token].should == [1,2,3,1234]
      end
    end
    context 'id key format' do
      before(:each) do
        @category.stub! :key_format => :to_i
      end
      it 'should call the other methods correctly' do
        @ary.should_receive(:<<).exactly(3).times.ordered.with 1
        @ary.should_receive(:<<).once.ordered.with 2
        @ary.should_receive(:<<).exactly(2).times.ordered.with 3
        @ary.should_receive(:<<).once.ordered.with 1234

        bundle.retrieve
      end
    end
    context 'other key format' do
      before(:each) do
        @category.stub! :key_format => :strip
      end
      it 'should call the other methods correctly' do
        @ary.should_receive(:<<).exactly(3).times.ordered.with '1'
        @ary.should_receive(:<<).once.ordered.with '2'
        @ary.should_receive(:<<).exactly(2).times.ordered.with '3'
        @ary.should_receive(:<<).once.ordered.with '1234'

        bundle.retrieve
      end
    end
    context 'no key format - default' do
      before(:each) do
        @category.stub! :key_format => nil
      end
      it 'should call the other methods correctly' do
        @ary.should_receive(:<<).exactly(3).times.ordered.with 1
        @ary.should_receive(:<<).once.ordered.with 2
        @ary.should_receive(:<<).exactly(2).times.ordered.with 3
        @ary.should_receive(:<<).once.ordered.with 1234

        bundle.retrieve
      end
    end
  end

  describe 'load_from_index_file' do
    it 'should call two methods in order' do
      bundle.should_receive(:load_from_prepared_index_generation_message).once.ordered
      bundle.should_receive(:retrieve).once.ordered

      bundle.load_from_prepared_index_file
    end
  end

  describe 'generate_derived' do
    it 'should call two methods in order' do
      bundle.should_receive(:generate_weights).once.ordered
      bundle.should_receive(:generate_similarity).once.ordered

      bundle.generate_derived
    end
  end

  describe 'generate_caches_from_memory' do
    it 'should call two methods in order' do
      bundle.should_receive(:cache_from_memory_generation_message).once.ordered
      bundle.should_receive(:generate_derived).once.ordered

      bundle.generate_caches_from_memory
    end
  end

  describe 'generate_caches_from_source' do
    it 'should call two methods in order' do
      bundle.should_receive(:load_from_prepared_index_file).once.ordered
      bundle.should_receive(:generate_caches_from_memory).once.ordered

      bundle.generate_caches_from_source
    end
  end

  describe 'dump' do
    it 'should trigger dumps' do
      bundle.stub! :timed_exclaim

      bundle.should_receive(:dump_inverted).once.with
      bundle.should_receive(:dump_weights).once.with
      bundle.should_receive(:dump_similarity).once.with
      bundle.should_receive(:dump_configuration).once.with

      bundle.dump
    end
  end

  describe 'raise_unless_cache_exists' do
    it "calls methods in order" do
      bundle.should_receive(:raise_unless_index_exists).once.ordered
      bundle.should_receive(:raise_unless_similarity_exists).once.ordered

      bundle.raise_unless_cache_exists
    end
  end
  describe 'raise_unless_index_exists' do
    context 'partial strategy saved' do
      before(:each) do
        strategy = stub :strategy, :saved? => true
        bundle.stub! :partial_strategy => strategy
      end
      it "calls the methods in order" do
        bundle.should_receive(:warn_if_index_small).once.ordered
        bundle.should_receive(:raise_unless_index_ok).once.ordered

        bundle.raise_unless_index_exists
      end
    end
    context 'partial strategy not saved' do
      before(:each) do
        strategy = stub :strategy, :saved? => false
        bundle.stub! :partial_strategy => strategy
      end
      it "calls nothing" do
        bundle.should_receive(:warn_if_index_small).never
        bundle.should_receive(:raise_unless_index_ok).never

        bundle.raise_unless_index_exists
      end
    end
  end
  describe 'raise_unless_similarity_exists' do
    context 'similarity strategy saved' do
      before(:each) do
        strategy = stub :strategy, :saved? => true
        bundle.stub! :similarity_strategy => strategy
      end
      it "calls the methods in order" do
        bundle.should_receive(:warn_if_similarity_small).once.ordered
        bundle.should_receive(:raise_unless_similarity_ok).once.ordered

        bundle.raise_unless_similarity_exists
      end
    end
    context 'similarity strategy not saved' do
      before(:each) do
        strategy = stub :strategy, :saved? => false
        bundle.stub! :similarity_strategy => strategy
      end
      it "calls nothing" do
        bundle.should_receive(:warn_if_similarity_small).never
        bundle.should_receive(:raise_unless_similarity_ok).never

        bundle.raise_unless_similarity_exists
      end
    end
  end
  describe 'warn_if_similarity_small' do
    context "files similarity cache small" do
      before(:each) do
        bundle.stub! :backend_similarity => stub(:backend_similarity, :cache_small? => true)
      end
      it "warns" do
        bundle.should_receive(:warn_cache_small).once.with :similarity

        bundle.warn_if_similarity_small
      end
    end
    context "files similarity cache not small" do
      before(:each) do
        bundle.stub! :backend_similarity => stub(:backend_similarity, :cache_small? => false)
      end
      it "does not warn" do
        bundle.should_receive(:warn_cache_small).never

        bundle.warn_if_similarity_small
      end
    end
  end
  describe 'raise_unless_similarity_ok' do
    context "files similarity cache ok" do
      before(:each) do
        bundle.stub! :backend_similarity => stub(:backend_similarity, :cache_ok? => true)
      end
      it "warns" do
        bundle.should_receive(:raise_cache_missing).never

        bundle.raise_unless_similarity_ok
      end
    end
    context "files similarity cache not ok" do
      before(:each) do
        bundle.stub! :backend_similarity => stub(:backend_similarity, :cache_ok? => false)
      end
      it "does not warn" do
        bundle.should_receive(:raise_cache_missing).once.with :similarity

        bundle.raise_unless_similarity_ok
      end
    end
  end

  describe 'initialization' do
    it 'should initialize the index correctly' do
      bundle.inverted.should == {}
    end
    it 'should initialize the weights index correctly' do
      bundle.weights.should == {}
    end
    it 'should initialize the similarity index correctly' do
      bundle.similarity.should == {}
    end
    it 'should initialize the configuration correctly' do
      bundle.configuration.should == {}
    end
    # it 'should initialize the partial strategy correctly' do
    #   bundle.partial_strategy.should == @partial
    # end
    # it 'should initialize the weights strategy correctly' do
    #   bundle.weights_strategy.should == @weights
    # end
    it 'should initialize the similarity strategy correctly' do
      bundle.similarity_strategy.should == @similarity
    end
  end

end