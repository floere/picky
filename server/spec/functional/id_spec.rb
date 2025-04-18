# encoding: utf-8
#
require 'spec_helper'

describe 'id option' do

  it 'can be given a different id (in-ruby based)' do
    data = Picky::Index.new :id do
      id :number
      category :text
    end

    require 'ostruct'

    thing = OpenStruct.new number: 1, text: 'ohai'
    other = OpenStruct.new number: 2, text: 'ohai kthxbye'

    data.add thing
    data.add other

    try = Picky::Search.new data

    try.search('text:kthxbye').ids.should == [2]
  end

  it 'can be given a different id (source based)' do
    require 'ostruct'

    things = []
    things << OpenStruct.new(number: 1, text: 'ohai')
    things << OpenStruct.new(number: 2, text: 'ohai kthxbye')

    data = Picky::Index.new :id do
      source { things }

      id :number, format: 'to_i'
      category :text
    end

    data.index

    try = Picky::Search.new data

    try.search('text:kthxbye').ids.should == [2]
  end

  it 'default is id' do
    index = Picky::Index.new :id do
      category :text
    end

    require 'ostruct'

    thing = OpenStruct.new id: 1, text: 'ohai'
    other = OpenStruct.new id: 2, text: 'ohai kthxbye'

    index.add thing
    index.add other

    try = Picky::Search.new index

    try.search('text:kthxbye').ids.should == [2]
  end

end