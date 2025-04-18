# encoding: utf-8

require 'spec_helper'

describe 'Multi Index Qualifiers' do
  it 'resolves the same qualifier to different categories on each index' do
    people = Picky::Index.new :people do
      category :title
      category :name, qualifiers: %i[name last_name]
    end
    books = Picky::Index.new :books do
      category :title, qualifiers: %i[title name]
      category :subtitle
    end

    person = Struct.new :id, :title, :name
    book   = Struct.new :id, :title, :subtitle

    people.add person.new(1, 'mister', 'pedro maria alhambra madrugada')
    books.add  book.new(2, 'the mister madrugada affair', 'the story of seventeen madrugada family members')

    try = Picky::Search.new people, books

    # We expect title to be mapped to:
    #  * the title category in index people
    #  * the title category in index books
    #
    # Resulting in mister being found in both.
    #
    try.search('title:mister').ids.should

    # This is a bit crazier.
    #
    # We expect name to be mapped to:
    #  * the name category in index people
    #  * the title category in index books
    #
    # Resulting in madrugada being found in both.
    #
    try.search('name:madrugada').ids.should == [1, 2]

    # If either would not work correctly, we would find:
    #   try.search('title:mister').ids.should == [1, 1]
    # or
    #   try.search('title:mister').ids.should == [2, 2]
    # since "title" would be resolved to the same
    # category in both cases.
    #
    # Or possibly get [1, 2, 2], if title is simply ignored.
  end
end
