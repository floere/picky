# encoding: utf-8
#
require 'spec_helper'

describe Internals::Tokenizers::Base do
  
  context 'with special instance' do
    let (:tokenizer) { described_class.new reject_token_if: lambda { |token| token.to_s.length < 2 || token == :hello } }
    it 'rejects tokens with length < 2' do
      tokenizer.reject([:'', :a, :ab, :abc]).should == [:ab, :abc]
    end
    it 'rejects tokens that are called :hello' do
      tokenizer.reject([:hel, :hell, :hello]).should == [:hel, :hell]
    end
  end
  
  context 'with normal instance' do
    let(:tokenizer) { described_class.new }

    describe 'reject_token_if' do
      it 'rejects empty tokens by default' do
        tokenizer.reject(['a', nil, '', 'b']).should == ['a', 'b']
      end
      it 'rejects tokens based on the given rejection criteria if set' do
        tokenizer.reject_token_if &:nil?

        tokenizer.reject(['a', nil, '', 'b']).should == ['a', '', 'b']
      end
    end

    describe "substitute(s)_characters*" do
      it "doesn't substitute if there is no substituter" do
        tokenizer.substitute_characters('abcdefghijklmnopqrstuvwxyzäöü').should == 'abcdefghijklmnopqrstuvwxyzäöü'
      end
      it "uses the substituter to replace characters" do
        tokenizer.substitutes_characters_with CharacterSubstituters::WestEuropean.new

        tokenizer.substitute_characters('abcdefghijklmnopqrstuvwxyzäöü').should == 'abcdefghijklmnopqrstuvwxyzaeoeue'
      end
      it "uses the european substituter as default" do
        tokenizer.substitutes_characters_with

        tokenizer.substitute_characters('abcdefghijklmnopqrstuvwxyzäöü').should == 'abcdefghijklmnopqrstuvwxyzaeoeue'
      end
    end

    describe "removes_characters_after_splitting" do
      context "without removes_characters_after_splitting called" do
        it "has remove_after_normalizing_illegals" do
          expect { tokenizer.remove_after_normalizing_illegals('any') }.to_not raise_error
        end
        it 'should define a remove_after_normalizing_illegals normalize_with_patterns does nothing' do
          unchanging = stub :unchanging
          
          tokenizer.remove_after_normalizing_illegals unchanging
        end
      end
      context "with removes_characters_after_splitting called" do
        before(:each) do
          tokenizer.removes_characters_after_splitting(/[afo]/)
        end
        it "has remove_after_normalizing_illegals" do
          expect { tokenizer.remove_after_normalizing_illegals('abcdefghijklmnop') }.to_not raise_error
        end
        it "removes illegal characters" do
          tokenizer.remove_after_normalizing_illegals('abcdefghijklmnop').should == 'bcdeghijklmnp'
        end
      end
    end

    describe "normalizes_words" do
      context "without normalizes_words called" do
        it "has normalize_with_patterns" do
          expect { tokenizer.normalize_with_patterns('any') }.to_not raise_error
        end
        it 'should define a method normalize_with_patterns does nothing' do
          unchanging = stub :unchanging
          
          tokenizer.normalize_with_patterns(unchanging).should == unchanging
        end
      end
      context "with normalizes_words called" do
        before(:each) do
          tokenizer.normalizes_words([
            [/st\./, 'sankt'],
            [/stras?s?e?/, 'str']
          ])
        end
        it "has normalize_with_patterns" do
          expect { tokenizer.normalize_with_patterns('a b/c.d') }.to_not raise_error
        end
        it "normalizes, but just the first one" do
          tokenizer.normalize_with_patterns('st. wegstrasse').should == 'sankt wegstrasse'
        end
      end
    end

    describe "splits_text_on" do
      context "without splits_text_on called" do
        it "has split" do
          lambda { tokenizer.split('any') }.should_not raise_error
        end
        it 'should define a method split that splits by default on \s' do
          tokenizer.split('a b/c.d').should == ['a', 'b/c.d']
        end
        it 'splits text on /\s/ by default' do
          tokenizer.split('this is a test').should == ['this', 'is', 'a', 'test']
        end
      end
      context "with removes_characters called" do
        before(:each) do
          tokenizer.splits_text_on(/[\s\.\/]/)
        end
        it "has split" do
          expect { tokenizer.split('a b/c.d') }.to_not raise_error
        end
        it "removes illegal characters" do
          tokenizer.split('a b/c.d').should == ['a','b','c','d']
        end
      end
    end

    describe "removes_characters" do
      context "without removes_characters called" do
        it "has remove_illegals" do
          expect { tokenizer.remove_illegals('any') }.to_not raise_error
        end
        it 'should define a method remove_illegals that does nothing' do
          unchanging = stub :unchanging
          
          tokenizer.remove_illegals unchanging
        end
      end
      context "with removes_characters called" do
        before(:each) do
          tokenizer.removes_characters(/[afo]/)
        end
        it "has remove_illegals" do
          expect { tokenizer.remove_illegals('abcdefghijklmnop') }.to_not raise_error
        end
        it "removes illegal characters" do
          tokenizer.remove_illegals('abcdefghijklmnop').should == 'bcdeghijklmnp'
        end
      end
    end

    describe 'stopwords' do
      context 'without stopwords given' do
        it 'should define a method remove_stopwords' do
          lambda { tokenizer.remove_stopwords('from this text') }.should_not raise_error
        end
        it 'should define a method remove_stopwords that does nothing' do
          tokenizer.remove_stopwords('from this text').should == 'from this text'
        end
        it 'should define a method remove_non_single_stopwords' do
          expect { tokenizer.remove_non_single_stopwords('from this text') }.to_not raise_error
        end
      end
      context 'with stopwords given' do
        before(:each) do
          tokenizer.stopwords(/r|e/)
        end
        it 'should define a method remove_stopwords' do
          lambda { tokenizer.remove_stopwords('from this text') }.should_not raise_error
        end
        it 'should define a method stopwords that removes stopwords' do
          tokenizer.remove_stopwords('from this text').should == 'fom this txt'
        end
        it 'should define a method remove_non_single_stopwords' do
          expect { tokenizer.remove_non_single_stopwords('from this text') }.to_not raise_error
        end
        it 'should define a method remove_non_single_stopwords that removes non-single stopwords' do
          tokenizer.remove_non_single_stopwords('rerere rerere').should == ' '
        end
        it 'should define a method remove_non_single_stopwords that does not single stopwords' do
          tokenizer.remove_non_single_stopwords('rerere').should == 'rerere'
        end
      end
      context 'error case' do
        before(:each) do
          tokenizer.stopwords(/any/)
        end
        it 'should not remove non-single stopwords with a star' do
          tokenizer.remove_non_single_stopwords('a*').should == 'a*'
        end
        it 'should not remove non-single stopwords with a tilde' do
          tokenizer.remove_non_single_stopwords('a~').should == 'a~'
        end
      end
    end
  end
  
end