# coding: utf-8
require 'spec_helper'

describe Tokenizers::Base do

  before(:each) do
    @tokenizer = Tokenizers::Base.new
  end

  context 'stopwords' do
    describe '.stopwords' do
      context 'without stopwords given' do
        it 'should define a method remove_stopwords' do
          lambda { @tokenizer.remove_stopwords('from this text') }.should_not raise_error
        end
        it 'should define a method remove_stopwords that does nothing' do
          @tokenizer.remove_stopwords('from this text').should == nil
        end
        it 'should not define a method remove_non_single_stopwords' do
          lambda { @tokenizer.remove_non_single_stopwords('from this text') }.should raise_error(NoMethodError)
        end
      end
      context 'with stopwords given' do
        before(:each) do
          class << @tokenizer
            stopwords(/r|e/)
          end
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
          class << @tokenizer
            stopwords(/any/)
          end
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

end