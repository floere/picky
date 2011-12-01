# encoding: utf-8
#
require 'spec_helper'

describe "exact first" do

  before(:each) do
    Picky::Indexes.clear_indexes
  end

  it 'returns exact results first' do
    index = Picky::Index.new :exact_first do
      source { [] }
      category :text, partial: Picky::Partial::Substring.new(from: 1)
    end

    require 'ostruct'
    exact   = OpenStruct.new id: 1, text: "disco"
    partial = OpenStruct.new id: 2, text: "discofox"
    index.add exact
    index.add partial

    normal = Picky::Search.new index
    normal.search("disco").ids.should == [2, 1] # 2 was added later.

    index = Picky::Wrappers::Category::ExactFirst.wrap index

    exact_first = Picky::Search.new index
    exact_first.search("disco").ids.should == [1, 2] # Exact first.
    exact_first.search("disc").ids.should  == [2, 1] # Not exact, so not first.
  end

  it 'can do dumps/loads etc.' do
    require 'ostruct'

    data = Picky::Index.new :exact_first do
      source { [
        OpenStruct.new(id: 1, text: "discofox"),
        OpenStruct.new(id: 2, text: "disco")
      ] }
      category :text, partial: Picky::Partial::Substring.new(from: 1)
    end
    normal = Picky::Search.new data
    Picky::Indexes.index_for_tests

    normal.search("disco").ids.should == [1, 2] # Ordering with which it was added.

    data = Picky::Wrappers::Category::ExactFirst.wrap data
    exact_first = Picky::Search.new data

    Picky::Indexes.index_for_tests

    exact_first.search("disco").ids.should == [2, 1] # Exact first.
    exact_first.search("disc").ids.should  == [1, 2] # Not exact, so not first.
  end

end