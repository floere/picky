# coding: utf-8
require 'spec_helper'

describe Internals::Tokenizers::Query do

  let(:tokenizer) { described_class.new }
  
  describe "default*" do
    before(:all) do
      @old = described_class.default
    end
    after(:all) do
      described_class.default = @old
    end
    it "has a reader" do
      lambda { described_class.default }.should_not raise_error
    end
    it "returns by default a new Index" do
      described_class.default.should be_kind_of(described_class)
    end
    it "has a writer" do
      lambda { described_class.default = :bla }.should_not raise_error
    end
    it "returns what has been written, if something has been written" do
      described_class.default = :some_default
      
      described_class.default.should == :some_default
    end
  end
  
  describe "maximum_tokens" do
    it "should be set to 5 by default" do
      tokenizer.maximum_tokens.should == 5
    end
    it "should be settable" do
      described_class.new(maximum_tokens: 3).maximum_tokens.should == 3
    end
  end
  
  describe 'preprocess' do
    it 'should call methods in order' do
      text = stub :text
      
      tokenizer.should_receive(:substitute_characters).once.with(text).and_return text
      tokenizer.should_receive(:remove_illegals).once.ordered.with text
      tokenizer.should_receive(:remove_non_single_stopwords).once.ordered.with text
      
      tokenizer.preprocess text
    end
    it 'should return the text unchanged by default' do
      text = "some text"
      
      tokenizer.preprocess(text).should == text
    end
  end
  
  describe 'process' do
    before(:each) do
      @tokens = mock :tokens, :null_object => true
    end
    it 'should call methods on the tokens in order' do
      @tokens.should_receive(:reject).once.ordered
      @tokens.should_receive(:cap).once.ordered
      @tokens.should_receive(:partialize_last).once.ordered

      tokenizer.process @tokens
    end
    it 'should return the tokens' do
      tokenizer.process(@tokens).should == @tokens
    end
  end

  describe 'pretokenize' do
    def self.it_should_pretokenize text, expected
      it "should pretokenize #{text} as #{expected}" do
        tokenizer.pretokenize(text).should == expected
      end
    end
    it_should_pretokenize 'test miau test', ['test', 'miau', 'test']
  end

  describe "tokenizing" do
    def self.it_should_tokenize_token(text, expected)
      it "should handle the #{text} case" do
        tokenizer.tokenize(text).map(&:text).should == expected
      end
    end
    it_should_tokenize_token 'simple tokenizing on \s', [:simple, :tokenizing, :on, :'\s']
  end
  
  describe 'normalize_with_patterns' do
    def self.it_should_pattern_normalize original, expected
      it "should normalize #{original} with pattern into #{expected}" do
        tokenizer.normalize_with_patterns(original).should == expected
      end
    end
    it_should_pattern_normalize 'no pattern normalization', 'no pattern normalization'
  end
  
  describe 'reject' do
    it 'should reject blank tokens' do
      tokenizer.reject(["some token answering to blank?", nil, nil]).should == ["some token answering to blank?"]
    end
  end
  
  describe "last token" do
    it "should be partial" do
      tokenizer.tokenize("First Second Third Last").last.instance_variable_get(:@partial).should be_true
    end
  end
  
  describe ".tokenize" do
    it "should return an Array of tokens" do
      tokenizer.tokenize('test test').to_a.should be_instance_of(Array)
    end
    it "should return an empty tokenized query if the query string is blank or empty" do
      tokenizer.tokenize('').map(&:to_s).should == []
    end
  end
  
end