# encoding: utf-8
#
require 'spec_helper'

describe "Regression" do

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