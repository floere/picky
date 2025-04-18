# coding: utf-8
#
require 'spec_helper'

describe Picky::Query::Combination do

  before(:each) do
    @bundle      = double :bundle, identifier: :bundle_name
    @token       = Picky::Query::Token.processed('some_text~', 'Some Original~')
    @category    = double :category,
                          bundle_for: @bundle,
                          name: :some_category_name,
                          identifier: 'some_category_identifier'

    @combination = described_class.new @token, @category, 3.14
  end

  describe 'to_s' do
    it "shows the combination's info" do
      @token.stub to_result: :token_result

      @combination.to_s.should == '(bundle_name,some_category_name:token_result)'
    end
  end

  describe 'to_result' do
    context 'functional with qualifier' do
      before(:each) do
        token = Picky::Query::Token.processed 'name:blä~', 'Blä~'

        @combination = Picky::Query::Combination.new token, @category, 3.14
      end
      it 'should return a correct result' do
        @combination.to_result.should == [:some_category_name, 'Blä~', 'blä'] # Note: Characters not substituted. That's ok.
      end
    end
    it 'should return a correct result' do
      @token.stub to_result: [:some_original_text, :some_text]

      @combination.to_result.should == [:some_category_name, :some_original_text, :some_text]
    end
  end

  describe 'identifier' do
    it 'should get the category name from the bundle' do
      @combination.identifier.should == 'bundle_name:inverted:some_text'
    end
  end

  describe 'ids' do
    it 'should call ids with the text on bundle' do
      @category.should_receive(:ids).once.with @token

      @combination.ids
    end
    it 'should not call it twice, but cache' do
      @category.stub ids: :some_ids
      @combination.ids

      @category.should_receive(:ids).never

      @combination.ids.should == :some_ids
    end
  end

  describe 'weight' do
    it 'should return the weight' do
      @combination.weight.should == 3.14
    end
  end

end
