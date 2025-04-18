require 'spec_helper'

describe 'Search#only' do
  it 'keeps allocations correctly' do
    index = Picky::Index.new :books do
      category :author
      category :title
      category :text
    end

    thing = Struct.new :id, :author, :title, :text
    index.add thing.new(1, 'peter', 'some title', 'some text')
    index.add thing.new(2, 'some name', 'some title', 'some text')

    try = Picky::Search.new index do
      only %i[author text],
           [:text]
    end

    # These allocations are now exclusively kept.
    #
    try.search('some some').allocations.to_result.should

    # These allocations are now exclusively kept.
    #
    try.search('some some some').allocations.to_result.should == [
      [:books, 2.0789999999999997, 2,
       [[:text, 'some', 'some'],   [:text, 'some', 'some'], [:text, 'some', 'some']], [2, 1]],
      # [:books, 2.0789999999999997, 2, [[:text, "some", "some"],   [:text, "some", "some"],  [:title, "some", "some"]],   [2, 1]],
      # [:books, 2.0789999999999997, 2, [[:text, "some", "some"],   [:title, "some", "some"], [:text, "some", "some"]],    [2, 1]],
      # [:books, 2.0789999999999997, 2, [[:text, "some", "some"],   [:title, "some", "some"], [:title, "some", "some"]],   [2, 1]],
      # [:books, 2.0789999999999997, 2, [[:title, "some", "some"],  [:text, "some", "some"],   [:text, "some", "some"]],   [2, 1]],
      # [:books, 2.0789999999999997, 2, [[:title, "some", "some"],  [:text, "some", "some"],   [:title, "some", "some"]],  [2, 1]],
      # [:books, 2.0789999999999997, 2, [[:title, "some", "some"],  [:title, "some", "some"],  [:text, "some", "some"]],   [2, 1]],
      # [:books, 2.0789999999999997, 2, [[:title, "some", "some"],  [:title, "some", "some"],  [:title, "some", "some"]],  [2, 1]],
      [:books, 1.386,              1,
       [[:author, 'some', 'some'], [:text, 'some', 'some'],   [:text, 'some', 'some']],   [2]],
      # [:books, 1.386,              1, [[:text, "some", "some"],   [:text, "some", "some"],   [:author, "some", "some"]], [2]],
      # [:books, 1.386,              1, [[:title, "some", "some"],  [:author, "some", "some"], [:title, "some", "some"]],  [2]],
      # [:books, 1.386,              1, [[:title, "some", "some"],  [:author, "some", "some"], [:text, "some", "some"]],   [2]],
      # [:books, 1.386,              1, [[:title, "some", "some"],  [:title, "some", "some"],  [:author, "some", "some"]], []],
      # [:books, 1.386,              1, [[:author, "some", "some"], [:text, "some", "some"],   [:title, "some", "some"]],  []],
      # [:books, 1.386,              1, [[:text, "some", "some"],   [:title, "some", "some"],  [:author, "some", "some"]], []],
      # [:books, 1.386,              1, [[:title, "some", "some"],  [:text, "some", "some"],   [:author, "some", "some"]], []],
      # [:books, 1.386,              1, [[:author, "some", "some"], [:title, "some", "some"],  [:text, "some", "some"]],   []],
      # [:books, 1.386,              1, [[:text, "some", "some"],   [:author, "some", "some"], [:title, "some", "some"]],  []],
      # [:books, 1.386,              1, [[:text, "some", "some"],   [:author, "some", "some"], [:text, "some", "some"]],   []],
      # [:books, 1.386,              1, [[:author, "some", "some"], [:title, "some", "some"],  [:title, "some", "some"]],  []],
      # [:books, 0.693,              1, [[:text, "some", "some"],   [:author, "some", "some"], [:author, "some", "some"]], []],
      # [:books, 0.693,              1, [[:author, "some", "some"], [:text, "some", "some"],   [:author, "some", "some"]], []],
      # [:books, 0.693,              1, [[:author, "some", "some"], [:title, "some", "some"],  [:author, "some", "some"]], []],
      # [:books, 0.693,              1, [[:author, "some", "some"], [:author, "some", "some"], [:title, "some", "some"]],  []],
      # [:books, 0.693,              1, [[:title, "some", "some"],  [:author, "some", "some"], [:author, "some", "some"]], []],
      [:books, 0.693,              1,
       [[:author, 'some', 'some'], [:author, 'some', 'some'], [:text, 'some', 'some']],   [2]]
      # [:books, 0.0,                1, [[:author, "some", "some"], [:author, "some", "some"], [:author, "some", "some"]], []]
    ]
  end

  it 'performs far better' do
    index = Picky::Index.new :books do
      category :author
      category :title
      category :text
    end

    thing = Struct.new :id, :author, :title, :text
    index.add thing.new(1, 'peter', 'some title', 'some text')
    index.add thing.new(2, 'some name', 'some title', 'some text')
    index.add thing.new(3, 'peter', 'some title', 'some text')
    index.add thing.new(4, 'some name', 'some title', 'some text')
    index.add thing.new(5, 'peter', 'some title', 'some text')
    index.add thing.new(6, 'some name', 'some title', 'some text')
    index.add thing.new(7, 'peter', 'some title', 'some text')
    index.add thing.new(8, 'some name', 'some title', 'some text')

    try = Picky::Search.new index

    # Reasonably fast.
    #
    performance_of { try.search('some some') }.should

    try.only %i[author text],
             %i[text text]

    # Much faster.
    #
    performance_of { try.search('some some') }.should < 0.000175
  end

  it 'offers the option only' do
    index = Picky::Index.new :only do
      category :category1
      category :category2
      category :category3
    end

    index.add Struct.new(:id, :category1, :category2, :category3).new(1, 'text1', 'text2', 'text3')

    try = Picky::Search.new index
    try.search('text1').ids.should
    try.search('text2').ids.should
    try.search('text3').ids.should

    expect do
      try_again = Picky::Search.new index do
        only :category1
      end
      try_again.search('text1').ids.should
      try_again.search('text2').ids.should
      try_again.search('text3').ids.should

      try_again.only :category2, :category3

      try_again.search('text1').ids.should
      try_again.search('text2').ids.should
      try_again.search('text3').ids.should

      try_again.search('category1:text1').ids.should
      try_again.search('category1:text2').ids.should
      try_again.search('category1:text3').ids.should

      try_again.search('category2:text1').ids.should
      try_again.search('category2:text2').ids.should
      try_again.search('category2:text3').ids.should

      try_again.search('category3:text1').ids.should
      try_again.search('category3:text2').ids.should
      try_again.search('category3:text3').ids.should

      try_again.search('category1,category2:text1').ids.should
      try_again.search('category1,category2:text2').ids.should
      try_again.search('category1,category2:text3').ids.should

      try_again.search('category1,category3:text1').ids.should
      try_again.search('category1,category3:text2').ids.should
      try_again.search('category1,category3:text3').ids.should

      try_again.search('category2,category3:text1').ids.should
      try_again.search('category2,category3:text2').ids.should
      try_again.search('category2,category3:text3').ids.should

      try_again.search('category1,category2,category3:text1').ids.should
      try_again.search('category1,category2,category3:text2').ids.should
      try_again.search('category1,category2,category3:text3').ids.should == [1]
    end.to raise_error
  end
end
