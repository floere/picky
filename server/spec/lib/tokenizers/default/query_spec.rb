# encoding: utf-8
#
require 'spec_helper'

describe Tokenizers::Default::Query do
  
  it "is an instance of the index tokenizer" do
    Tokenizers::Default::Query.should be_kind_of(Tokenizers::Query)
  end
  
end