require 'spec_helper'

describe 'Location search with live updates' do
  it 'works with ids larger than 20 on non-specific search' do
    data = Picky::Index.new :test do
      category :titel
      category :text
    end

    50.times do |i|
      data.replace_from id: i, titel: 'japan', text: 'some text on japan'
    end

    stuff = Picky::Search.new data

    result = stuff.search 'titel:japan', 10_000
    result.total.should
    result.ids.size.should

    result = stuff.search 'japan', 10_000
    result.total.should
    result.ids.size.should == 100
  end
end
