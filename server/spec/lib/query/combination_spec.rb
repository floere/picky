# coding: utf-8
#
require 'spec_helper'

describe 'Query::Combination' do

  before(:each) do
    @bundle      = stub :bundle, :identifier => :bundle_name
    @token       = stub :token, :text => :some_text, :partial => false, :similar? => true
    @category    = stub :category, :bundle_for => @bundle, :name => :some_category_name

    @combination = Query::Combination.new @token, @category
  end
  
  describe "to_s" do
    it "shows the combination's info" do
      @token.stub! :to_result => :token_result
      
      @combination.to_s.should == 'bundle_name some_category_name:token_result'
    end
  end
  
  describe 'hash' do
    it 'should hash the token and the bundle' do
      @combination.hash.should == [@token.to_s, @bundle].hash
    end
  end

  describe 'in?' do
    before(:each) do
      @combination.stub! :identifier => :some_identifier
    end
    it 'should check if the given identifiers include the identifier' do
      @combination.in?([:some_other_identifier, :some_identifier, :some_other_identifier]).should == true
    end
    it 'should check if the given identifiers include the identifier' do
      @combination.in?([:some_other_identifier, :some_other_identifier]).should == false
    end
  end

  describe 'to_result' do
    context 'functional with qualifier' do
      before(:each) do
        token = Tokenizers::Query.new.tokenize('name:Blä~').first

        @combination = Query::Combination.new token, @category
      end
      it 'should return a correct result' do
        @combination.to_result.should == [:some_category_name, 'Blä~', :blae]
      end
    end
    it 'should return a correct result' do
      @token.stub! :to_result => [:some_original_text, :some_text]
      @combination.stub! :identifier => :some_identifier

      @combination.to_result.should == [:some_identifier, :some_original_text, :some_text]
    end
  end

  describe 'identifier' do
    it 'should get the category name from the bundle' do
      @combination.identifier.should == :some_category_name
    end
  end

  describe 'ids' do
    it 'should call ids with the text on bundle' do
      @bundle.should_receive(:ids).once.with :some_text

      @combination.ids
    end
    it 'should not call it twice, but cache' do
      @bundle.stub! :ids => :some_ids
      @combination.ids

      @bundle.should_receive(:ids).never

      @combination.ids.should == :some_ids
    end
  end

  describe 'weight' do
    it 'should call weight with the text on bundle' do
      @bundle.should_receive(:weight).once.with :some_text

      @combination.weight
    end
    it 'should not call it twice, but cache' do
      @bundle.stub! :weight => :some_weight
      @combination.weight

      @bundle.should_receive(:weight).never

      @combination.weight.should == :some_weight
    end
  end

end