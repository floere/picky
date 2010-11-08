# encoding: utf-8
require 'spec_helper'

describe Configuration::Indexes do
  
  before(:each) do
    @config = Configuration::Indexes.new
  end
  
  describe "types" do
    it "exists" do
      lambda { @config.types }.should_not raise_error
    end
    it "is initially empty" do
      @config.types.should be_empty
    end
  end
  
  describe "default_tokenizer" do
    it "is a default tokenizer" do
      @config.default_tokenizer.should be_kind_of(Tokenizers::Index)
    end
    it "does not cache" do
      @config.default_tokenizer.should_not == @config.default_tokenizer
    end
  end
  
end