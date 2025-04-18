require 'spec_helper'

describe 'qualifier remapping' do
  it 'can have new qualifiers' do
    index = Picky::Index.new :qualifier_remapping do
      category :a
    end

    QualifierRemappingThing = Struct.new(:id, :a, :b)

    index.add QualifierRemappingThing.new(1, 'a', 'b')

    try = Picky::Search.new index

    # Picky finds nothing.
    #
    try.search('b').ids.should

    # Add a new category and a thing.
    #
    index.category :b
    index.add QualifierRemappingThing.new(2, 'c', 'b')

    # It finds it.
    #
    try.search('b').ids.should

    # It already also finds it with a qualifier!
    #
    try.search('b:b').ids.should == [2]
  end
end
