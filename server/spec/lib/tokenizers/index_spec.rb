# encoding: utf-8
#
require 'spec_helper'

# TODO CLEAN UP.
#
describe Tokenizers::Index do
  
  before(:each) do
    @tokenizer = Tokenizers::Index.new
  end
  
  describe "remove_illegal_characters" do
    it "should not remove ' from a query by default" do
      @tokenizer.remove_illegals("Lugi's").should == "Lugi's"
    end
  end

  describe "reject!" do
    it "should reject tokens if blank" do
      t1 = stub(:token, :to_s => '')
      t2 = stub(:token, :to_s => 'not blank')
      t3 = stub(:token, :to_s => '')

      @tokenizer.reject([t1, t2, t3]).should == [t2]
    end
  end

  describe "tokenize" do
    describe "normalizing" do
      def self.it_should_normalize_token(text, expected)
        it "should handle the #{text} case" do
          @tokenizer.tokenize(text).to_a.should == [expected].compact
        end
      end
      # defaults
      it_should_normalize_token 'it_should_not_normalize_by_default', :it_should_not_normalize_by_default
    end
    describe "tokenizing" do
      def self.it_should_tokenize_token(text, expected)
        it "should handle the #{text} case" do
          @tokenizer.tokenize(text).to_a.should == expected
        end
      end
      # defaults
      it_should_tokenize_token "splitting on \\s", [:splitting, :on, :"\\s"]
      it_should_tokenize_token 'und', [:und]
    end
  end

end