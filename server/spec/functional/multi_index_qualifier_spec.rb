# encoding: utf-8
#
require 'spec_helper'

describe 'Multi Index Qualifiers' do
  
  it 'resolves the same qualifier to different categories on each index' do
    people = Picky::Index.new :people do
      category :title
      category :name, qualifiers: [:name, :last_name]
    end
    books = Picky::Index.new :books do
      category :title, qualifiers: [:title, :name]
      category :subtitle
    end

    person = Struct.new :id, :title, :name
    book   = Struct.new :id, :title, :subtitle

    people.add person.new(1, 'mister', 'pedro maria alhambra madrugada')
    
    books.add book.new(2, 'the mister madrugada affair', 'the story of seventeen madrugada family members')

    try = Picky::Search.new people, books
    
    try.search('title:mister').ids.should == [1, 2]
    try.search('name:madrugada').ids.should == [1, 2]
  end
  
end