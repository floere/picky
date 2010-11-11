require 'spec_helper'

describe Indexed::Category do

  before(:each) do
    @type       = stub :type, :name => :some_type
    @partial    = stub :partial
    @weights    = stub :weights
    @similarity = stub :similarity
    @category   = Indexed::Category.new :some_name, @type, :partial    => @partial,
                                                           :weights    => @weights,
                                                           :similarity => @similarity,
                                                           :qualifiers => [:q, :qualifier]
    
    @exact   = stub :exact, :dump => nil
    @category.stub! :exact => @exact
    
    @partial = stub :partial, :dump => nil
    @category.stub! :partial => @partial
    @category.stub! :exclaim
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
  
  describe 'load_from_cache' do
    it 'should call two methods' do
      @exact.should_receive(:load).once
      @partial.should_receive(:load).once
      
      @category.load_from_cache
    end
  end

end