# encoding: utf-8
#
require 'spec_helper'

describe "Dynamic weights" do

  # This quickly tests the dynamic weights.
  #
  context 'various cases' do
    it 'stopwords destroy ids (final: id reference on attribute)' do
      index = Picky::Index.new :dynamic_weights do
        source { [] }
        category :text1, weights: Picky::Weights::Constant.new
        category :text2, weights: Picky::Weights::Constant.new(3.14)
        category :text3, weights: Picky::Weights::Dynamic.new { |str_or_sym| str_or_sym.size }
        category :text4 # Default
      end

      require 'ostruct'

      thing = OpenStruct.new id: 1, text1: "ohai", text2: "hello", text3: "world", text4: "kthxbye"

      index.add thing

      try = Picky::Search.new index

      try.search("text1:ohai").allocations.first.score.should  == 0.0
      try.search("text2:hello").allocations.first.score.should == 3.14
      try.search("text3:world").allocations.first.score.should == 5
      try.search("text4:kthxbye").allocations.first.score.should == 0
    end
  end

end