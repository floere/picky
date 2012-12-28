# encoding: utf-8
#
require 'spec_helper'

# Shows that lists of categories can be ignored.
#
describe 'ignoring allocations' do

  it 'works' do
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
end
