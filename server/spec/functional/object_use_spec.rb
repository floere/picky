require 'spec_helper'

describe 'Object Use' do
  it 'is not too high' do
    index = Picky::Index.new :object_use do
      category :text1
      category :text2
      category :text3
      category :text4
    end
    try = Picky::Search.new index

    thing = Struct.new(:id, :text1, :text2, :text3, :text4)
    index.add thing.new(1, 'one', 'two', 'three', 'four')

    # Pre-run.
    #

    try.search 'one'
    try.search 'one two three'
    try.search 'text1:one'
    try.search 'text1:one text2:two text3:three'

    # Actual tests.
    #

    s = 'one'
    result = mark do
      try.search s
    end
    expect(result).to eq({}) # No new strings since nothing is split.

    s = 'one two three'
    result = mark do
      try.search s
    end
    expect(result).to eq(
      'three' => 1,
      'two' => 1,
      'one' => 1,
      'one two three' => 2 # TODO Is GC'd.
    )

    result = mark do
      try.search 'text1:one'
    end
    result.should # Only the necessary split strings.

    s = 'text1:one text2:two text3:three'
    result = mark do
      try.search s
    end
    expect(result).to eq(
      'three' => 1,
      'two' => 1,
      'one' => 1,
      'text3' => 1,
      'text2' => 1,
      'text1' => 1,
      'text3:three' => 1,
      'text2:two' => 1,
      'text1:one' => 1,
      'text1:one text2:two text3:three' => 2 # Sadly this one is left.
    ) # Only the necessary split strings.

    s = 'text1:one text2:two text3,text4:three'
    result = mark do
      try.search s
    end
    expect(result).to eq(
      'three' => 1,
      'two' => 1,
      'one' => 1,
      'text3,text4' => 2, # TODO
      'text3' => 1,
      'text4' => 1,
      'text2' => 1,
      'text1' => 1,
      'text1:one' => 1,
      'text2:two' => 1,
      'text3,text4:three' => 1,
      'text1:one text2:two text3,text4:three' => 3 # Sadly this one is left.
    )
  end
end
