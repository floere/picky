# encoding: utf-8
#
require 'spec_helper'

# Shows that lists of categories can be ignored.
#
describe 'ignoring allocations/categories' do

  it 'ignores categories/allocations correctly' do
    index = Picky::Index.new :books do
      category :author
      category :title
      category :text
    end

    thing = Struct.new :id, :author, :title, :text
    index.add thing.new(1, 'peter', 'some title', 'some text')
    index.add thing.new(2, 'some name', 'some title', 'some text')
    
    try = Picky::Search.new index do
      ignore [:author, :text],
             :text,
             [:text, :text]
    end
    
    # These categories/allocations are now removed.
    #
    try.search('some some').allocations.to_result.should == [
      # [:books, 1.386, 2, [[:text, "some", "some"],   [:text, "some", "some"]],   [2, 1]],
      [:books, 1.386, 2, [[:title, "some", "some"]],                             [2, 1]],
      [:books, 1.386, 2, [                           [:title, "some", "some"]],  [2, 1]],
      [:books, 1.386, 2, [[:title, "some", "some"],  [:title, "some", "some"]],  [2, 1]],
      [:books, 0.693, 1, [[:title, "some", "some"],  [:author, "some", "some"]], [2]],
      # [:books, 0.693, 1, [[:author, "some", "some"], [:text, "some", "some"]],   [2]],
      [:books, 0.693, 1, [[:author, "some", "some"], [:title, "some", "some"]],  [2]],
      [:books, 0.693, 1, [                           [:author, "some", "some"]], [2]],
      [:books, 0.0,   1, [[:author, "some", "some"], [:author, "some", "some"]], [2]]
    ]
  end
  
  it 'ignores allocations correctly' do
    index = Picky::Index.new :books do
      category :author
      category :title
      category :text
    end

    thing = Struct.new :id, :author, :title, :text
    index.add thing.new(1, 'peter', 'some title', 'some text')
    index.add thing.new(2, 'some name', 'some title', 'some text')
    
    try = Picky::Search.new index do
      ignore [:author, :text],
             [:text, :text]
    end
    
    # These allocations are now removed.
    #
    try.search('some some').allocations.to_result.should == [
      # [:books, 1.386, 2, [[:text, "some", "some"],   [:text, "some", "some"]],   [2, 1]],
      [:books, 1.386, 2, [[:text, "some", "some"],   [:title, "some", "some"]],  [2, 1]],
      [:books, 1.386, 2, [[:title, "some", "some"],  [:text, "some", "some"]],   [2, 1]],
      [:books, 1.386, 2, [[:title, "some", "some"],  [:title, "some", "some"]],  [2, 1]],
      [:books, 0.693, 1, [[:title, "some", "some"],  [:author, "some", "some"]], [2]],
      # [:books, 0.693, 1, [[:author, "some", "some"], [:text, "some", "some"]],   [2]],
      [:books, 0.693, 1, [[:author, "some", "some"], [:title, "some", "some"]],  [2]],
      [:books, 0.693, 1, [[:text, "some", "some"],   [:author, "some", "some"]], [2]],
      [:books, 0.0,   1, [[:author, "some", "some"], [:author, "some", "some"]], [2]]
    ]
  end
  
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
      only [:author, :text],
           [:text, :text]
    end
    
    # These allocations are now exclusively kept.
    #
    try.search('some some').allocations.to_result.should == [
      [:books, 1.386, 2, [[:text, "some", "some"],   [:text, "some", "some"]],   [2, 1]],
      # [:books, 1.386, 2, [[:text, "some", "some"],   [:title, "some", "some"]],  [2, 1]],
      # [:books, 1.386, 2, [[:title, "some", "some"],  [:text, "some", "some"]],   [2, 1]],
      # [:books, 1.386, 2, [[:title, "some", "some"],  [:title, "some", "some"]],  [2, 1]],
      # [:books, 0.693, 1, [[:title, "some", "some"],  [:author, "some", "some"]], [2]],
      [:books, 0.693, 1, [[:author, "some", "some"], [:text, "some", "some"]],   [2]],
      # [:books, 0.693, 1, [[:author, "some", "some"], [:title, "some", "some"]],  [2]],
      # [:books, 0.693, 1, [[:text, "some", "some"],   [:author, "some", "some"]], [2]],
      # [:books, 0.0,   1, [[:author, "some", "some"], [:author, "some", "some"]], [2]]
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
    performance_of { try.search('some some') }.should < 0.0005
    
    try.only [:author, :text],
             [:text, :text]
    
    # Much faster.
    #
    performance_of { try.search('some some') }.should < 0.000175
  end
end
