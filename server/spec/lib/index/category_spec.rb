require 'spec_helper'

describe Index::Category do

  before(:each) do
    @field      = stub :field, :name => :some_name
    @type       = stub :type, :name => :some_type
    @partial    = stub :partial
    @weights    = stub :weights
    @similarity = stub :similarity
    @category   = Index::Category.new @field, @type, :partial => @partial, :weights => @weights, :similarity => @similarity

    @exact   = stub :exact, :dump => nil
    @category.stub! :exact => @exact

    @partial = stub :partial, :dump => nil
    @category.stub! :partial => @partial
  end

  describe 'dump_caches' do
    it 'should dump the exact index' do
      @exact.should_receive(:dump).once.with

      @category.dump_caches
    end
    it 'should dump the partial index' do
      @partial.should_receive(:dump).once.with

      @category.dump_caches
    end
  end

  describe 'generate_derived_partial' do
    it 'should delegate to partial' do
      @partial.should_receive(:generate_derived).once.with

      @category.generate_derived_partial
    end
  end

  describe 'generate_derived_exact' do
    it 'should delegate to exact' do
      @exact.should_receive(:generate_derived).once.with

      @category.generate_derived_exact
    end
  end

  describe 'generate_indexes_from_exact_index' do
    it 'should call three method in order' do
      @category.should_receive(:generate_derived_exact).once.with().ordered
      @category.should_receive(:generate_partial).once.with().ordered
      @category.should_receive(:generate_derived_partial).once.with().ordered

      @category.generate_indexes_from_exact_index
    end
  end

  describe 'weight' do
    before(:each) do
      @token = stub :token, :text => :some_text
    end
    context 'partial bundle' do
      before(:each) do
        @category.stub! :bundle_for => @partial
      end
      it 'should receive weight with the token text' do
        @partial.should_receive(:weight).once.with :some_text

        @category.weight @token
      end
    end
    context 'exact bundle' do
      before(:each) do
        @category.stub! :bundle_for => @exact
      end
      it 'should receive weight with the token text' do
        @exact.should_receive(:weight).once.with :some_text

        @category.weight @token
      end
    end
  end

  describe 'ids' do
    before(:each) do
      @token = stub :token, :text => :some_text
    end
    context 'partial bundle' do
      before(:each) do
        @category.stub! :bundle_for => @partial
      end
      it 'should receive ids with the token text' do
        @partial.should_receive(:ids).once.with :some_text

        @category.ids @token
      end
    end
    context 'exact bundle' do
      before(:each) do
        @category.stub! :bundle_for => @exact
      end
      it 'should receive ids with the token text' do
        @exact.should_receive(:ids).once.with :some_text

        @category.ids @token
      end
    end
  end

  describe 'combination_for' do
    context 'no weight for token' do
      before(:each) do
        @category.stub! :weight => nil
      end
      it 'should return nil' do
        @category.combination_for(:anything).should == nil
      end
    end
    context 'weight for token' do
      before(:each) do
        @token = stub :token, :text => :some_text
        @category.stub! :weight => :some_weight, :bundle_for => :bundle
      end
      it 'should return a new combination' do
        @category.combination_for(@token).should be_kind_of(::Query::Combination)
      end
      it 'should create the combination correctly' do
        ::Query::Combination.should_receive(:new).once.with @token, @category

        @category.combination_for @token
      end
    end
  end

  describe 'bundle_for' do
    it 'should return the right bundle' do
      token = stub :token, :partial? => false

      @category.bundle_for(token).should == @exact
    end
    it 'should return the right bundle' do
      token = stub :token, :partial? => true

      @category.bundle_for(token).should == @partial
    end
  end

  describe 'generate_caches_from_memory' do
    it 'should delegate to partial' do
      @partial.should_receive(:generate_caches_from_memory).once.with

      @category.generate_caches_from_memory
    end
  end

  describe 'generate_partial' do
    it 'should return whatever the partial generation returns' do
      @exact.stub! :index
      @partial.stub! :generate_partial_from => :generation_returns

      @category.generate_partial
    end
    it 'should use the exact index to generate the partial index' do
      exact_index = stub :exact_index
      @exact.stub! :index => exact_index
      @partial.should_receive(:generate_partial_from).once.with(exact_index)

      @category.generate_partial
    end
  end

  describe 'generate_caches_from_source' do
    it 'should delegate to exact' do
      @exact.should_receive(:generate_caches_from_source).once.with

      @category.generate_caches_from_source
    end
  end

  describe 'generate_caches' do
    before(:each) do
      @category.stub! :exclaim
    end
    it 'should call three method in order' do
      @category.should_receive(:generate_caches_from_source).once.with().ordered
      @category.should_receive(:generate_partial).once.with().ordered
      @category.should_receive(:generate_caches_from_memory).once.with().ordered
      
      @category.generate_caches
    end
  end
  
  describe 'load_from_cache' do
    it 'should call two methods' do
      @exact.should_receive(:load).once
      @partial.should_receive(:load).once
      
      @category.load_from_cache
    end
  end

end