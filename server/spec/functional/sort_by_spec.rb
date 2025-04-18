# encoding: utf-8
#
require 'spec_helper'

describe 'id option' do

  it 'can sort' do
    data = Picky::Index.new :id do
      id :id
      category :text, partial: Picky::Partial::Postfix.new(from: 1)
      category :number
    end

    require 'ostruct'

    thing = OpenStruct.new id: 1, number: 2, text: 'aabcdef bcdef'
    other = OpenStruct.new id: 2, number: 1, text: 'abcdef bbcdef'

    data.add thing
    data.add other

    sorting_order = {
      thing.id => thing,
      other.id => other
    }

    try = Picky::Search.new data

    # Sort by number.
    #
    results = try.search('a')
    
    results.sort_by { |id| sorting_order[id].number }
    
    results.ids.should == [2, 1]
    
    # Sort by text.
    #
    results = try.search('a')
    
    results.sort_by { |id| sorting_order[id].text }
    
    results.ids.should == [1, 2]
    
    # Sort by number.
    #
    results = try.search('a* b')
    
    results.sort_by { |id| sorting_order[id].number }
    
    results.ids.should == [2, 1]
    
    # Sort by text.
    #
    results = try.search('a* b')
    
    results.sort_by { |id| sorting_order[id].text }
    
    results.ids.should == [1, 2]
  end
  

end
