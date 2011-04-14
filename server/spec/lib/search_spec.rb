# coding: utf-8
#
require 'spec_helper'

describe Search do
  
  before(:each) do
    @type      = stub :type
    @index     = stub :some_index, :internal_indexed => @type
  end
  
  describe 'tokenized' do
    let(:search) { described_class.new }
    it 'delegates to the tokenizer' do
      tokenizer = stub :tokenizer
      search.stub! :tokenizer => tokenizer
      
      tokenizer.should_receive(:tokenize).once.with :some_text
      
      search.tokenized :some_text
    end
  end
  
  describe 'boost' do
    let(:search) do
      described_class.new do
        boost [:a, :b] => +3,
              [:c, :d] => -1
      end
    end
    it 'works' do
      search.weights.should == Query::Weights.new([:a, :b] => 3, [:c, :d] => -1)
    end
  end
  
  describe 'tokenizer' do
    context 'no tokenizer predefined' do
      let(:search) { described_class.new }
      it 'returns the default tokenizer' do
        search.tokenizer.should == Internals::Tokenizers::Query.default
      end
    end
    context 'tokenizer predefined' do
      let(:predefined) { stub(:tokenizer, :tokenize => nil) }
      context 'by way of hash' do
        let(:search) { described_class.new(tokenizer: predefined) }
        it 'returns the predefined tokenizer' do
          search.tokenizer.should == predefined
        end
      end
      context 'by way of DSL' do
        let(:search) { pre = predefined; described_class.new { searching pre } }
        it 'returns the predefined tokenizer' do
          search.tokenizer.should == predefined
        end
      end
    end
    
  end
  
  describe 'combinations_type_for' do
    let(:search) { described_class.new }
    it 'returns a specific Combination for a specific input' do
      some_source = stub(:source, :harvest => nil)
      search.combinations_type_for([Index::Memory.new(:gu, source: some_source)]).should == Internals::Query::Combinations::Memory
    end
    it 'just works on the same types' do
      search.combinations_type_for([:blorf, :blarf]).should == Internals::Query::Combinations::Memory
    end
    it 'just uses standard combinations' do
      search.combinations_type_for([:blorf]).should == Internals::Query::Combinations::Memory
    end
    it 'raises on multiple types' do
      expect do
        search.combinations_type_for [:blorf, "blarf"]
      end.to raise_error(Search::DifferentTypesError)
    end
    it 'raises with the right message on multiple types' do
      expect do
        search.combinations_type_for [:blorf, "blarf"]
      end.to raise_error("Currently it isn't possible to mix Symbol and String Indexes in the same Search instance.")
    end
  end
  
  describe "weights handling" do
    it "creates a default weight when no weights are given" do
      search = described_class.new
      
      search.weights.should be_kind_of(Query::Weights)
    end
    it "handles :weights options when not yet wrapped" do
      search = described_class.new :weights => { [:a, :b] => +3 }
      
      search.weights.should be_kind_of(Query::Weights)
    end
    it "handles :weights options when already wrapped" do
      search = described_class.new :weights => Query::Weights.new([:a, :b] => +3)
      
      search.weights.should be_kind_of(Query::Weights)
    end
  end
  
  describe "search_with_text" do
    before(:each) do
      @search = Search.new
    end
    it "delegates to search" do
      @search.stub! :tokenized => :tokens
      
      @search.should_receive(:search).once.with :tokens, :results, :offset
      
      @search.search_with_text :text, :results, :offset
    end
    it "uses the tokenizer" do
      @search.should_receive(:tokenized).once.with :text
      
      @search.search_with_text :text, :anything
    end
  end
  
  describe 'initializer' do
    context 'with tokenizer' do
      before(:each) do
        @tokenizer = stub :tokenizer, :tokenize => :some_tokenized_text
        @search    = Search.new @index, tokenizer: @tokenizer
      end
      it 'should tokenize using the tokenizer' do
        @search.tokenized('some text').should == :some_tokenized_text
      end
    end
  end
  
  describe 'to_s' do
    before(:each) do
      @type.stub! :name => :some_index
    end
    context 'with weights' do
      before(:each) do
        @search = Search.new @index, weights: :some_weights
      end
      it 'works correctly' do
        @search.to_s.should == 'Search(some_index, weights: some_weights)'
      end
    end
    context 'without weights' do
      before(:each) do
        @search = Search.new @index
      end
      it 'works correctly' do
        @search.to_s.should == 'Search(some_index)'
      end
    end
  end

end