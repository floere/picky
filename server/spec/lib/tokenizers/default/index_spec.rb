# encoding: utf-8
#
require 'spec_helper'

describe Tokenizers::Default::Index do
  
  it "is an instance of the index tokenizer" do
    Tokenizers::Default::Index.should be_kind_of(Tokenizers::Index)
  end
  
end