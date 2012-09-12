# encoding: utf-8
#
require 'spec_helper'

describe Picky::Tokenizer do

  describe 'with wrong/incorrectly spelled option' do
    it 'informs the user nicely' do
      expect {
        described_class.new rejetcs_token_if: :blank?.to_proc
      }.to raise_error(%Q{The option "rejetcs_token_if" is not a valid option for a Picky tokenizer.\nPlease see https://github.com/floere/picky/wiki/Indexing-configuration for valid options.})
    end
  end

  context 'with special instance' do
    let (:tokenizer) { described_class.new rejects_token_if: lambda { |token| token.to_s.length < 2 || token == :hello }, case_sensitive: true }
    it 'rejects tokens with length < 2' do
      tokenizer.reject([:'', :a, :ab, :abc]).should == [:ab, :abc]
    end
    it 'rejects tokens that are called :hello' do
      tokenizer.reject([:hel, :hell, :hello]).should == [:hel, :hell]
    end
    describe 'to_s' do
      it 'spits out the right text' do
        tokenizer.to_s.should == <<-EXPECTED
Removes characters: -
Stopwords:          -
Splits text on:     /\\s/
Normalizes words:   -
Rejects tokens?     Yes, see line 16 in app/application.rb
Substitutes chars?  -
Case sensitive?     Yes.
EXPECTED
      end
    end
  end

  context 'with normal instance' do
    let(:tokenizer) { described_class.new }

        describe 'to_s' do
          it 'spits out the right text' do
            tokenizer.to_s.should == <<-EXPECTED
Removes characters: -
Stopwords:          -
Splits text on:     /\\s/
Normalizes words:   -
Rejects tokens?     -
Substitutes chars?  -
Case sensitive?     -
EXPECTED
          end
        end

    describe 'rejects_token_if' do
      it 'rejects empty tokens by default' do
        tokenizer.reject(['a', nil, '', 'b']).should == ['a', 'b']
      end
      it 'rejects tokens based on the given rejection criteria if set' do
        tokenizer.rejects_token_if :nil?.to_proc

        tokenizer.reject(['a', nil, '', 'b']).should == ['a', '', 'b']
      end
    end

    describe "substitute(s)_characters*" do
      it "doesn't substitute if there is no substituter" do
        tokenizer.substitute_characters('abcdefghijklmnopqrstuvwxyzäöü').should == 'abcdefghijklmnopqrstuvwxyzäöü'
      end
      it 'raises if nothing with #substitute is given' do
        expect { tokenizer.substitutes_characters_with Object.new }.
          to raise_error(<<-ERROR)
The substitutes_characters_with option needs a character substituter,
which responds to #substitute(text) and returns substituted_text."
ERROR
      end
      it "uses the substituter to replace characters" do
        tokenizer.substitutes_characters_with Picky::CharacterSubstituters::WestEuropean.new

        tokenizer.substitute_characters('abcdefghijklmnopqrstuvwxyzäöü').should == 'abcdefghijklmnopqrstuvwxyzaeoeue'
      end
      it "uses the european substituter as default" do
        tokenizer.substitutes_characters_with

        tokenizer.substitute_characters('abcdefghijklmnopqrstuvwxyzäöü').should == 'abcdefghijklmnopqrstuvwxyzaeoeue'
      end
    end

    describe "normalizes_words" do
      it 'handles broken arguments' do
        expect { tokenizer.normalizes_words(:not_an_array) }.to raise_error(ArgumentError)
      end
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
            [/stras?s?e?/, 'str'],
            [/\+/, 'plus'],
            [/\&/, 'and']
          ])
        end
        it "has normalize_with_patterns" do
          expect { tokenizer.normalize_with_patterns('a b/c.d') }.to_not raise_error
        end
        it "normalizes, but just the first one" do
          tokenizer.normalize_with_patterns('st. wegstrasse').should == 'sankt wegstrasse'
        end
        it "works correctly" do
          tokenizer.normalize_with_patterns('camera +').should == 'camera plus'
        end
        it "works correctly" do
          tokenizer.normalize_with_patterns('alice & bob').should == 'alice and bob'
        end
      end
    end

    describe "splits_text_on" do
      it 'handles nonbroken arguments' do
        expect { tokenizer.splits_text_on("hello") }.to_not raise_error(ArgumentError)
      end
      it 'handles broken arguments' do
        expect { tokenizer.splits_text_on(:gnorf) }.to raise_error(ArgumentError)
      end
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
      it 'handles broken arguments' do
        expect { tokenizer.removes_characters("hello") }.to raise_error(ArgumentError)
      end
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
      it 'handles broken arguments' do
        expect { tokenizer.stopwords("hello") }.to raise_error(ArgumentError)
      end
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
  
  context 'from' do
    context 'options hash' do
      it 'creates a tokenizer' do
        described_class.from(splits_text_on: /\t/).
          tokenize("hello\tworld").should == [['hello', 'world'], ['hello', 'world']]
      end
    end
    context 'tokenizer' do
      let(:tokenizer) do
        Class.new do
          def tokenize text
            ['unmoved', 'by', 'your', 'texts']
          end
        end.new
      end
      it 'creates a tokenizer' do
        described_class.from(tokenizer).
          tokenize("hello\tworld").should == ['unmoved', 'by', 'your', 'texts']
      end
    end
    context 'invalid tokenizer' do
      it 'raises with a nice error message' do
        expect {
          described_class.from Object.new
        }.to raise_error(<<-ERROR)
indexing options should be either
* a Hash
or
* an object that responds to #tokenize(text) => [[token1, token2, ...], [original1, original2, ...]]
ERROR
      end
      it 'raises with a nice error message' do
        expect {
          described_class.from Object.new, 'some_index'
        }.to raise_error(<<-ERROR)
indexing options for some_index should be either
* a Hash
or
* an object that responds to #tokenize(text) => [[token1, token2, ...], [original1, original2, ...]]
ERROR
      end
      it 'raises with a nice error message' do
        expect {
          described_class.from Object.new, 'some_index', 'some_category'
        }.to raise_error(<<-ERROR)
indexing options for some_index:some_category should be either
* a Hash
or
* an object that responds to #tokenize(text) => [[token1, token2, ...], [original1, original2, ...]]
ERROR
      end
    end
  end

end