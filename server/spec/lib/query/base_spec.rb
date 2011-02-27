# coding: utf-8
#
require 'spec_helper'

describe Query::Base do
  
  describe 'combinations_type_for' do
    let(:query) { described_class.new }
    it 'returns a specific Combination for a specific input' do
      query.combinations_type_for([Index::Memory.new(:gu, :ga)]).should == Internals::Query::Combinations::Memory
    end
    it 'just works on the same types' do
      query.combinations_type_for([:blorf, :blarf]).should == Internals::Query::Combinations::Memory
    end
    it 'just uses standard combinations' do
      query.combinations_type_for([:blorf]).should == Internals::Query::Combinations::Memory
    end
    it 'raises on multiple types' do
      expect do
        query.combinations_type_for [:blorf, "blarf"]
      end.to raise_error(Query::Base::DifferentTypesError)
    end
    it 'raises with the right message on multiple types' do
      expect do
        query.combinations_type_for [:blorf, "blarf"]
      end.to raise_error("Currently it isn't possible to mix Symbol and String Indexes in the same Query.")
    end
  end
  
  describe "weights handling" do
    it "creates a default weight when no weights are given" do
      query = described_class.new
      
      query.weights.should be_kind_of(Query::Weights)
    end
    it "handles :weights options when not yet wrapped" do
      query = described_class.new :weights => { [:a, :b] => +3 }
      
      query.weights.should be_kind_of(Query::Weights)
    end
    it "handles :weights options when already wrapped" do
      query = described_class.new :weights => Query::Weights.new([:a, :b] => +3)
      
      query.weights.should be_kind_of(Query::Weights)
    end
  end
  
  describe "empty_results" do
    before(:each) do
      @query = Query::Full.new
      
      @result_type = stub :result_type
      @query.stub! :result_type => @result_type
    end
    it "returns a new result type" do
      @result_type.should_receive(:new).once.with :some_offset
      
      @query.empty_results :some_offset
    end
    it "returns a new result type with default offset" do
      @result_type.should_receive(:new).once.with 0
      
      @query.empty_results
    end
  end
  
  describe "search_with_text" do
    before(:each) do
      @query = Query::Full.new
    end
    it "delegates to search" do
      @query.stub! :tokenized => :tokens
      
      @query.should_receive(:search).once.with :tokens, :offset
      
      @query.search_with_text :text, :offset
    end
    it "uses the tokenizer" do
      @query.should_receive(:tokenized).once.with :text
      
      @query.search_with_text :text, :anything
    end
  end
  
  describe 'reduce' do
    context 'real' do
      before(:each) do
        @allocations = stub :allocations
        @query       = Query::Full.new
      end
      context 'reduce_to_amount not set' do
        it 'should not call anything on the allocations' do
          @allocations.should_receive(:reduce_to).never
          
          @query.reduce @allocations
        end
      end
      context 'reduce_to_amount set' do
        before(:each) do
          @query.reduce_to_amount = :some_amount
        end
        it 'should call reduce_to on the allocations' do
          @allocations.should_receive(:reduce_to).once.with :some_amount
          
          @query.reduce @allocations
        end
      end
    end
    context 'stubbed' do
      before(:each) do
        @allocations = stub :allocations
        @query       = Query::Full.new
      end
      context 'reduce_to_amount not set' do
        it 'should not call anything on the allocations' do
          @allocations.should_receive(:reduce_to).never
          
          @query.reduce @allocations
        end
      end
      context 'reduce_to_amount set' do
        before(:each) do
          @query.stub! :reduce_to_amount => :some_amount
        end
        it 'should call reduce_to on the allocations' do
          @allocations.should_receive(:reduce_to).once.with :some_amount
          
          @query.reduce @allocations
        end
      end
    end
  end
  
  before(:each) do
    @type      = stub :type
    @index     = stub :some_index, :indexed => @type
  end
  
  describe 'initializer' do
    context 'with tokenizer' do
      before(:each) do
        @tokenizer = stub :tokenizer, :tokenize => :some_tokenized_text
        @query     = Query::Full.new @index, tokenizer: @tokenizer
      end
      it 'should tokenize using the tokenizer' do
        @query.tokenized('some text').should == :some_tokenized_text
      end
    end
  end
  
  describe 'to_s' do
    context 'with weights' do
      before(:each) do
        @query = Query::Full.new @index, weights: :some_weights
      end
      it 'works correctly' do
        @query.to_s.should == 'Query::Full, weights: some_weights'
      end
    end
    context 'without weights' do
      before(:each) do
        @query = Query::Full.new @index
      end
      it 'works correctly' do
        @query.to_s.should == 'Query::Full'
      end
    end
  end

end