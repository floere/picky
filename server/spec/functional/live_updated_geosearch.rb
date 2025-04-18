# encoding: utf-8
#
require 'spec_helper'

describe 'Location search with live updates' do

  it 'works with location search' do
    index = Picky::Index.new :live_location_search do
      ranged_category :x, 1
      ranged_category :y, 1
    end

    thing = Struct.new :id, :x, :y
    index.add thing.new(1,  0,  0)
    index.add thing.new(2,  1,  8)
    index.add thing.new(3, -2,  1)
    index.add thing.new(4,  1, -1)
    index.add thing.new(5, -3, -3)
    index.add thing.new(6, -3.5, -3.5)

    try = Picky::Search.new index

    # Exact.
    #
    try.search('x:0 y:0').ids.should == [1]
    try.search('x:1 y:8').ids.should == [2]

    # Near.
    #
    try.search('x:1.1 y:8.1').ids.should == [2]
    try.search('x:1.2 y:8.2').ids.should == [2]
    try.search('x:1.5 y:8.5').ids.should == [2]
    try.search('x:1.9 y:8.9').ids.should == [2]
    try.search('x:2.0 y:9.0').ids.should == []

    # Fractions.
    #
    try.search('x:-3.25 y:-3.25').ids.should == [6, 5]

    # 1-D search.
    #
    try.search('x:1').ids.should == [4, 2]

    # Removal of 1.
    #
    index.remove 1
    try.search('x:0 y:0').ids.should == [] # See first "should".
  end

  it 'works with volumetric search' do
    index = Picky::Index.new :live_location_search do
      ranged_category :x, 1
      ranged_category :y, 1
      ranged_category :z, 1
    end

    thing = Struct.new :id, :x, :y, :z
    index.add thing.new(1,  0,    0  ,  0  )
    index.add thing.new(2,  1,    8  ,  3  )
    index.add thing.new(3, -2,    1  ,  5  )
    index.add thing.new(4,  1,   -1  ,  2  )
    index.add thing.new(5, -3,   -3  , -3  )
    index.add thing.new(6, -3.5, -3.5, -3.5)

    try = Picky::Search.new index

    # Exact.
    #
    try.search('x:0 y:0 z:0').ids.should == [1]
    try.search('x:1 y:8 z:3').ids.should == [2]

    # Near.
    #
    try.search('x:1.1 y:8.1 z:3.1').ids.should == [2]
    try.search('x:1.2 y:8.2 z:3.2').ids.should == [2]
    try.search('x:1.5 y:8.5 z:3.5').ids.should == [2]
    try.search('x:1.9 y:8.9 z:3.5').ids.should == [2]
    try.search('x:2.0 y:9.0 z:4.0').ids.should == []

    # Fractions.
    #
    try.search('x:-3.25 y:-3.25 z:-3.25').ids.should == [6, 5]

    # 1-D search.
    #
    try.search('x:1').ids.should == [4, 2]

    # Removal of 1.
    #
    index.remove 1
    try.search('x:0 y:0 z:0').ids.should == [] # See first "should".
  end

  it 'works with geosearch' do
    index = Picky::Index.new :live_geosearch do
      geo_categories :x, :y, 1 # 1 km -> but one searches in degrees!
    end

    thing = Struct.new :id, :x, :y
    index.add thing.new(1,  0,  0)
    index.add thing.new(2,  1,  8)
    index.add thing.new(3, -2,  1)
    index.add thing.new(4,  1, -1)
    index.add thing.new(5, -3, -3)
    index.add thing.new(6, -3.5, -3.5)

    try = Picky::Search.new index

    # Exact.
    #
    try.search('x:0 y:0').ids.should == [1]
    try.search('x:1 y:8').ids.should == [2]

    # Near (in degrees!).
    #
    try.search('x:1.00001 y:8.00001').ids.should == [2]
    try.search('x:1.001   y:8.001').ids.should == [2]
    try.search('x:1.01    y:8.01').ids.should == []

    # 1-D search.
    #
    try.search('x:1').ids.should == [4, 2]

    # Removal of 1.
    #
    index.remove 1
    try.search('x:0 y:0').ids.should == [] # See first "should".
  end

end
