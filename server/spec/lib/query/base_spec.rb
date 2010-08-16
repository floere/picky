# coding: utf-8
require 'spec_helper'

describe 'Query::Base' do
  
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
  
  describe 'initializer' do
    context 'with tokenizer' do
      before(:each) do
        @tokenizer = stub :tokenizer, :tokenize => :some_tokenized_text
        @query     = Query::Full.new 'some query', :some_index, :tokenizer => @tokenizer
      end
      it 'should tokenize using the tokenizer' do
        @query.tokenized('some text').should == :some_tokenized_text
      end
    end
  end

  describe "results_from" do
    describe 'Full' do
      before(:each) do
        @query = Query::Full.new 'some query', :some_index
      end
      it "should work" do
        allocations = stub :allocations, :process! => true

        @query.results_from allocations
      end
    end
    describe 'Live' do
      before(:each) do
        @query = Query::Live.new 'some query', :some_index
      end
      it "should work" do
        allocations = stub :allocations, :process! => true

        @query.results_from allocations
      end
    end
  end

  describe "sorted_allocations" do
    before(:each) do
      @index_class = stub :index_class
      @query = Query::Base.new @index_class
    end
    it "should generate the right kind of allocations" do
      tokens = @query.tokenized 'some query'
      
      @index_class.stub! :possible_combinations => []
      
      @query.sorted_allocations(tokens).should be_kind_of(Query::Allocations)
    end
  end

end