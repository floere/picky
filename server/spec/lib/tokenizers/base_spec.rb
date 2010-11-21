# encoding: utf-8
#
require 'spec_helper'

describe Tokenizers::Base do

  before(:each) do
    @tokenizer = Tokenizers::Base.new
  end
  
  describe "substitute(s)_characters*" do
    it "doesn't substitute if there is no substituter" do
      @tokenizer.substitute_characters('abcdefghijklmnopqrstuvwxyzäöü').should == 'abcdefghijklmnopqrstuvwxyzäöü'
    end
    it "uses the substituter to replace characters" do
      @tokenizer.substitutes_characters_with CharacterSubstituters::WestEuropean.new
      
      @tokenizer.substitute_characters('abcdefghijklmnopqrstuvwxyzäöü').should == 'abcdefghijklmnopqrstuvwxyzaeoeue'
    end
    it "uses the european substituter as default" do
      @tokenizer.substitutes_characters_with
      
      @tokenizer.substitute_characters('abcdefghijklmnopqrstuvwxyzäöü').should == 'abcdefghijklmnopqrstuvwxyzaeoeue'
    end
  end
  
  describe "removes_characters_after_splitting" do
    context "without removes_characters_after_splitting called" do
      it "has remove_after_normalizing_illegals" do
        lambda { @tokenizer.remove_after_normalizing_illegals('any') }.should_not raise_error
      end
      it 'should define a remove_after_normalizing_illegals normalize_with_patterns does nothing' do
        unchanging = stub :unchanging
        @tokenizer.remove_after_normalizing_illegals unchanging
      end
    end
    context "with removes_characters_after_splitting called" do
      before(:each) do
        @tokenizer.removes_characters_after_splitting(/[afo]/)
      end
      it "has remove_after_normalizing_illegals" do
        lambda { @tokenizer.remove_after_normalizing_illegals('abcdefghijklmnop') }.should_not raise_error
      end
      it "removes illegal characters" do
        @tokenizer.remove_after_normalizing_illegals('abcdefghijklmnop').should == 'bcdeghijklmnp'
      end
    end
  end
  
  describe "normalizes_words" do
    context "without normalizes_words called" do
      it "has normalize_with_patterns" do
        lambda { @tokenizer.normalize_with_patterns('any') }.should_not raise_error
      end
      it 'should define a method normalize_with_patterns does nothing' do
        unchanging = stub :unchanging
        @tokenizer.normalize_with_patterns(unchanging).should == unchanging
      end
    end
    context "with normalizes_words called" do
      before(:each) do
        @tokenizer.normalizes_words([
          [/st\./, 'sankt'],
          [/stras?s?e?/, 'str']
        ])
      end
      it "has normalize_with_patterns" do
        lambda { @tokenizer.normalize_with_patterns('a b/c.d') }.should_not raise_error
      end
      it "normalizes, but just the first one" do
        @tokenizer.normalize_with_patterns('st. wegstrasse').should == 'sankt wegstrasse'
      end
    end
  end
  
  describe "splits_text_on" do
    context "without splits_text_on called" do
      it "has split" do
        lambda { @tokenizer.split('any') }.should_not raise_error
      end
      it 'should define a method split that splits by default on \s' do
        @tokenizer.split('a b/c.d').should == ['a', 'b/c.d']
      end
      it 'splits text on /\s/ by default' do
        @tokenizer.split('this is a test').should == ['this', 'is', 'a', 'test']
      end
    end
    context "with removes_characters called" do
      before(:each) do
        @tokenizer.splits_text_on(/[\s\.\/]/)
      end
      it "has split" do
        lambda { @tokenizer.split('a b/c.d') }.should_not raise_error
      end
      it "removes illegal characters" do
        @tokenizer.split('a b/c.d').should == ['a','b','c','d']
      end
    end
  end
  
  describe "removes_characters" do
    context "without removes_characters called" do
      it "has remove_illegals" do
        lambda { @tokenizer.remove_illegals('any') }.should_not raise_error
      end
      it 'should define a method remove_illegals that does nothing' do
        unchanging = stub :unchanging
        @tokenizer.remove_illegals unchanging
      end
    end
    context "with removes_characters called" do
      before(:each) do
        @tokenizer.removes_characters(/[afo]/)
      end
      it "has remove_illegals" do
        lambda { @tokenizer.remove_illegals('abcdefghijklmnop') }.should_not raise_error
      end
      it "removes illegal characters" do
        @tokenizer.remove_illegals('abcdefghijklmnop').should == 'bcdeghijklmnp'
      end
    end
  end
  
  describe 'contracts_expressions' do
    context 'without contract_expressions called' do
      it 'should define a method contract' do
        lambda { @tokenizer.contract('from this text') }.should_not raise_error
      end
      it 'should define a method contract that does nothing' do
        unchanging = stub :unchanging
        @tokenizer.contract unchanging
      end
    end
    context 'with contracts_expressions called' do
      before(:each) do
        @tokenizer.contracts_expressions(/Mister|Mr./, 'mr')
      end
      it 'should define a method remove_stopwords' do
        lambda { @tokenizer.contract('from this text') }.should_not raise_error
      end
      it 'should define a method contract that contracts expressions' do
        @tokenizer.contract('Mister Meyer, Mr. Peter').should == 'mr Meyer, mr Peter'
      end
    end
  end
  
  describe 'stopwords' do
    context 'without stopwords given' do
      it 'should define a method remove_stopwords' do
        lambda { @tokenizer.remove_stopwords('from this text') }.should_not raise_error
      end
      it 'should define a method remove_stopwords that does nothing' do
        @tokenizer.remove_stopwords('from this text').should == 'from this text'
      end
      it 'should define a method remove_non_single_stopwords' do
        lambda { @tokenizer.remove_non_single_stopwords('from this text') }.should_not raise_error
        
      end
    end
    context 'with stopwords given' do
      before(:each) do
        @tokenizer.stopwords(/r|e/)
      end
      it 'should define a method remove_stopwords' do
        lambda { @tokenizer.remove_stopwords('from this text') }.should_not raise_error
      end
      it 'should define a method stopwords that removes stopwords' do
        @tokenizer.remove_stopwords('from this text').should == 'fom this txt'
      end
      it 'should define a method remove_non_single_stopwords' do
        lambda { @tokenizer.remove_non_single_stopwords('from this text') }.should_not raise_error
      end
      it 'should define a method remove_non_single_stopwords that removes non-single stopwords' do
        @tokenizer.remove_non_single_stopwords('rerere rerere').should == ' '
      end
      it 'should define a method remove_non_single_stopwords that does not single stopwords' do
        @tokenizer.remove_non_single_stopwords('rerere').should == 'rerere'
      end
    end
    context 'error case' do
      before(:each) do
        @tokenizer.stopwords(/any/)
      end
      it 'should not remove non-single stopwords with a star' do
        @tokenizer.remove_non_single_stopwords('a*').should == 'a*'
      end
      it 'should not remove non-single stopwords with a tilde' do
        @tokenizer.remove_non_single_stopwords('a~').should == 'a~'
      end
    end
  end
end