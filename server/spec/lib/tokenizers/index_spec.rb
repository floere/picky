# encoding: utf-8
#
require 'spec_helper'

describe Internals::Tokenizers::Index do
  
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
  
  describe "remove_removes_characters" do
    it "should not remove ' from a query by default" do
      tokenizer.remove_illegals("Lugi's").should == "Lugi's"
    end
  end

  describe "reject!" do
    it "should reject tokens if blank" do
      tokenizer.reject(['', 'not blank', '']).should == ['not blank']
    end
  end
  
  describe "tokenize" do
    describe "normalizing" do
      def self.it_should_normalize_token(text, expected)
        it "should handle the #{text} case" do
          tokenizer.tokenize(text).to_a.should == [expected].compact
        end
      end
      # defaults
      #
      it_should_normalize_token 'it_should_not_normalize_by_default', :it_should_not_normalize_by_default
    end
    describe "tokenizing" do
      def self.it_should_tokenize_token(text, expected)
        it "should handle the #{text} case" do
          tokenizer.tokenize(text).to_a.should == expected
        end
      end
      # defaults
      #
      it_should_tokenize_token "splitting on \\s", [:splitting, :on, :"\\s"]
      it_should_tokenize_token 'und', [:und]
      it_should_tokenize_token '7',   [:'7']
    end
  end

end