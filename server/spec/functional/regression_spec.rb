# encoding: utf-8
#
require 'spec_helper'

describe 'Regression' do
  
  it 'does not get confused' do
    index = Picky::Index.new :dynamic_weights do
      category :text1
      category :text2
      category :text3
      category :text4
    end
    try = Picky::Search.new index

    try.search('hello hello hello').allocations.size.should == 0

    thing = Struct.new(:id, :text1, :text2, :text3, :text4)
    index.add thing.new(1, 'hello', 'hello', 'hello', 'world')

    try.search('hello hello hello').allocations.size.should == 27

    index.add thing.new(2, 'hello', 'hello', 'hello', 'world')
    index.add thing.new(3, 'hello', 'hello', 'hello', 'world')
    index.add thing.new(4, 'hello', 'hello', 'hello', 'world')
    index.add thing.new(5, 'hello', 'hello', 'hello', 'world')

    try.search('hello hello hello').allocations.size.should == 27

    index.add thing.new(6, 'world', 'world', 'world', 'hello')

    try.search('hello hello world').allocations.size.should == 64
  end

  # # This was described by Niko
  # # and references a case where
  # # an attribute and the id referenced
  # # to the same String.
  # #
  # context 'fun cases' do
  #   it 'stopwords destroy ids (final: id reference on attribute)' do
  #     index = Picky::Index.new :stopwords do
  #       key_format :to_sym
  #       indexing splits_text_on: /[\\\/\s\"\'\&_,;:]+/i,
  #                stopwords: /\b(and|the|or|on|of|in|der|die|das|und|oder)\b/i
  #       category :text
  #     end
  #
  #     referenced = "this and that"
  #
  #     require 'ostruct'
  #
  #     thing = OpenStruct.new id: referenced, text: referenced
  #
  #     index.add thing
  #
  #     try = Picky::Search.new index
  #
  #     try.search("this").ids.should == ["this  that"]
  #   end
  # end

end
