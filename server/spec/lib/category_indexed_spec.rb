require 'spec_helper'

describe Picky::Category do

  before(:each) do
    @index = Picky::Index.new :some_index do
      source []
    end
    @partial_strategy    = double :partial, :each_partial => nil, :use_exact_for_partial? => false
    @weight_strategy     = double :weights, :saved? => true, :weight_for => :some_weight
    @similarity_strategy = double :similarity, :encode => nil, :prioritize => nil

    @exact   = double :exact, :dump => nil
    @partial = double :partial, :dump => nil

    @category = described_class.new :some_name, @index, :partial    => @partial_strategy,
                                                        :weight     => @weight_strategy,
                                                        :similarity => @similarity_strategy,
                                                        :qualifiers => [:q, :qualifier]

    @category.stub! :exclaim
  end

  describe 'partial' do
    context 'default' do
      before(:each) do
        @category = described_class.new :some_name, @index
      end
      context 'with a partial strategy that uses the exact index' do
        before(:each) do
          @partial_strategy.stub! :use_exact_for_partial? => true
        end
        it 'returns the partial index' do
          @category.partial.should be_kind_of(Picky::Bundle)
        end
      end
      context 'with a partial strategy that uses the partial index (default)' do
        it 'returns the partial index' do
          @category.partial.should be_kind_of(Picky::Bundle)
        end
      end
    end
    context 'indexed_bundle_class defined differently' do
      before(:each) do
        index = Picky::Index.new(:some_index_name) do
          source []
        end
        @category = described_class.new :some_name, index
      end
      context 'with a partial strategy that uses the exact index' do
        before(:each) do
          @partial_strategy.stub! :use_exact_for_partial? => true
        end
        it 'returns the partial index' do
          @category.partial.should be_kind_of(Picky::Bundle)
        end
      end
      context 'with a partial strategy that uses the partial index (default)' do
        it 'returns the partial index' do
          @category.partial.should be_kind_of(Picky::Bundle)
        end
      end
    end
  end

  describe 'weight' do
    let(:token) { double :token, :text => :some_text }
    context 'without range' do
      before :each do
        token.stub! :range => nil
      end
      context 'partial bundle' do
        before(:each) do
          @category.stub! :bundle_for => @partial
        end
        it 'should receive weight with the token text' do
          @partial.should_receive(:weight).once.with :some_text

          @category.weight token
        end
      end
      context 'exact bundle' do
        before(:each) do
          @category.stub! :bundle_for => @exact
        end
        it 'should receive weight with the token text' do
          @exact.should_receive(:weight).once.with :some_text

          @category.weight token
        end
      end
    end
    context 'with range' do
      before :each do
        token.stub! :range => [1, 3]
      end
      context 'partial bundle' do
        before(:each) do
          @category.stub! :bundle_for => @partial
        end
        it 'should receive weight with the token text' do
          @partial.should_receive(:weight).once.times.with(1).and_return(1)
          @partial.should_receive(:weight).once.times.with(2).and_return(2)
          @partial.should_receive(:weight).once.times.with(3).and_return(3)

          @category.weight(token).should == 6
        end
        it 'returns nil if none hit' do
          @partial.should_receive(:weight).once.times.with(1).and_return(nil)
          @partial.should_receive(:weight).once.times.with(2).and_return(nil)
          @partial.should_receive(:weight).once.times.with(3).and_return(nil)

          @category.weight(token).should == nil
        end
      end
      context 'exact bundle' do
        before(:each) do
          @category.stub! :bundle_for => @exact
        end
        it 'should receive weight with the token text' do
          @exact.should_receive(:weight).once.times.with(1).and_return(1)
          @exact.should_receive(:weight).once.times.with(2).and_return(2)
          @exact.should_receive(:weight).once.times.with(3).and_return(3)

          @category.weight(token).should == 6
        end
      end
    end
  end

  describe 'ids' do
    let(:token) { double :token, :text => :some_text }
    context 'without range' do
      before(:each) { token.stub! :range => nil }
      context 'partial bundle' do
        before(:each) do
          @category.stub! :bundle_for => @partial
        end
        it 'should receive ids with the token text' do
          @partial.should_receive(:ids).once.with :some_text

          @category.ids token
        end
      end
      context 'exact bundle' do
        before(:each) do
          @category.stub! :bundle_for => @exact
        end
        it 'should receive ids with the token text' do
          @exact.should_receive(:ids).once.with :some_text

          @category.ids token
        end
      end
    end
    context 'with range' do
      before(:each) { token.stub! :range => [1, 3] }
      context 'partial bundle' do
        before(:each) do
          @category.stub! :bundle_for => @partial
        end
        it 'should receive ids with the token text' do
          @partial.should_receive(:ids).once.with(1).and_return [1]
          @partial.should_receive(:ids).once.with(2).and_return [2]
          @partial.should_receive(:ids).once.with(3).and_return [3]

          @category.ids(token).should == [1,2,3]
        end
      end
      context 'exact bundle' do
        before(:each) do
          @category.stub! :bundle_for => @exact
        end
        it 'should receive ids with the token text' do
          @exact.should_receive(:ids).once.with(1).and_return [1]
          @exact.should_receive(:ids).once.with(2).and_return [2]
          @exact.should_receive(:ids).once.with(3).and_return [3]

          @category.ids(token).should == [1,2,3]
        end
      end
    end
  end

  # describe 'combination_for' do
  #   context 'no weight for token' do
  #     before(:each) do
  #       @category.stub! :weight => nil
  #     end
  #     it 'should return nil' do
  #       @category.combination_for(:anything).should == nil
  #     end
  #   end
  #   context 'weight for token' do
  #     before(:each) do
  #       @token = double :token, :text => :some_text
  #       @category.stub! :weight => :some_weight, :bundle_for => :bundle
  #     end
  #     it 'should return a new combination' do
  #       @category.combination_for(@token).should be_kind_of(Picky::Query::Combination)
  #     end
  #     it 'should create the combination correctly' do
  #       Picky::Query::Combination.should_receive(:new).once.with @token, @category
  # 
  #       @category.combination_for @token
  #     end
  #   end
  # end

  context 'stubbed exact/partial' do
    before(:each) do
      @category.stub! :exact => (@exact = double :exact)
      @category.stub! :partial => (@partial = double :partial)
    end

    describe 'load' do
      it 'should call two methods' do
        @category.should_receive(:clear_realtime).once
        @exact.should_receive(:load).once
        @partial.should_receive(:load).once

        @category.load
      end
    end
  end

end