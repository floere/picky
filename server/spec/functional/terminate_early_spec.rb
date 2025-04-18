# encoding: utf-8

require 'spec_helper'

describe 'Search#terminate_early' do
  it 'terminates early' do
    index = Picky::Index.new :terminate_early do
      category :text1
      category :text2
      category :text3
      category :text4
    end

    thing = Struct.new :id, :text1, :text2, :text3, :text4
    index.add thing.new(1, 'hello', 'hello', 'hello', 'hello')
    index.add thing.new(2, 'hello', 'hello', 'hello', 'hello')
    index.add thing.new(3, 'hello', 'hello', 'hello', 'hello')
    index.add thing.new(4, 'hello', 'hello', 'hello', 'hello')
    index.add thing.new(5, 'hello', 'hello', 'hello', 'hello')
    index.add thing.new(6, 'hello', 'hello', 'hello', 'hello')

    try = Picky::Search.new index
    try.search('hello').ids.should

    try = Picky::Search.new index
    try.search('hello', 30).ids.should

    try = Picky::Search.new index do
      terminate_early
    end
    try.search('hello', 3).ids.should

    try = Picky::Search.new index do
      terminate_early
    end
    try.search('hello', 9).ids.should

    try = Picky::Search.new index do
      terminate_early with_extra_allocations: 0
    end
    try.search('hello', 9).ids.should
    try.search('hello', 9, 4).ids.should
    try.search('hello', 9, 7).ids.should
    try.search('hello', 9, 10).ids.should
    try.search('hello', 9, 13).ids.should
    try.search('hello', 9, 16).ids.should
    try.search('hello', 9, 19).ids.should
    try.search('hello', 9, 22).ids.should
    try.search('hello', 9, 25).ids.should

    try.search('hello', 9).to_hash[:allocations].size.should
    try.search('hello', 9, 4).to_hash[:allocations].size.should
    try.search('hello', 9, 7).to_hash[:allocations].size.should
    try.search('hello', 9, 10).to_hash[:allocations].size.should
    try.search('hello', 9, 13).to_hash[:allocations].size.should
    try.search('hello', 9, 16).to_hash[:allocations].size.should
    try.search('hello', 9, 19).to_hash[:allocations].size.should
    try.search('hello', 9, 22).to_hash[:allocations].size.should
    try.search('hello', 9, 25).to_hash[:allocations].size.should

    try = Picky::Search.new index do
      terminate_early 0
    end
    try.search('hello').ids.should

    try = Picky::Search.new index do
      terminate_early with_extra_allocations: 0
    end
    try.search('hello').ids.should

    try = Picky::Search.new index do
      terminate_early 2
    end
    try.search('hello', 13).ids.should
    try.search('hello', 13, 4).ids.should
    try.search('hello', 13, 8).ids.should
    try.search('hello', 13, 12).ids.should
    try.search('hello', 13, 16).ids.should

    try.search('hello', 13).to_hash[:allocations].size.should
    try.search('hello', 13, 4).to_hash[:allocations].size.should
    try.search('hello', 13, 8).to_hash[:allocations].size.should
    try.search('hello', 13, 12).to_hash[:allocations].size.should
    try.search('hello', 13, 16).to_hash[:allocations].size.should

    try.search('hello', 13).allocations.map(&:count).should
    try.search('hello', 13, 4).allocations.map(&:count).should
    try.search('hello', 13, 8).allocations.map(&:count).should
    try.search('hello', 13, 12).allocations.map(&:count).should
    try.search('hello', 13, 16).allocations.map(&:count).should

    try = Picky::Search.new index do
      terminate_early with_extra_allocations: 2
    end
    try.search('hello').ids.should

    try = Picky::Search.new index do
      terminate_early with_extra_allocations: 1234
    end
    try.search('hello').ids.should

    try = Picky::Search.new index do
      terminate_early 1
    end
    try.search('hello', 1).ids.should
    try.search('hello', 1, 4).ids.should
    try.search('hello', 1, 8).ids.should
    try.search('hello', 1, 12).ids.should
    try.search('hello', 1, 16).ids.should

    try.search('hello', 1).to_hash[:allocations].size.should
    try.search('hello', 1, 4).to_hash[:allocations].size.should
    try.search('hello', 1, 8).to_hash[:allocations].size.should
    try.search('hello', 1, 12).to_hash[:allocations].size.should
    try.search('hello', 1, 16).to_hash[:allocations].size.should
    try.search('hello', 1, 20).to_hash[:allocations].size.should
    try.search('hello', 1, 24).to_hash[:allocations].size.should

    try.search('hello', 1).allocations.map(&:count).should
    try.search('hello', 1, 4).allocations.map(&:count).should
    try.search('hello', 1, 8).allocations.map(&:count).should
    try.search('hello', 1, 12).allocations.map(&:count).should
    try.search('hello', 1, 16).allocations.map(&:count).should
    try.search('hello', 1, 20).allocations.map(&:count).should
    try.search('hello', 1, 24).allocations.map(&:count).should

    result_hash = try.search('hello', 1, 0).to_hash
    result_hash[:allocations].should
    result_hash[:offset].should
    result_hash[:total].should

    result_hash = try.search('hello', 1, 12).to_hash
    result_hash[:allocations].should
    result_hash[:offset].should
    result_hash[:total].should

    GC.start

    try_slow = Picky::Search.new index
    slow = performance_of do
      try_slow.search 'hello'
    end
    try_fast = Picky::Search.new index do
      terminate_early
    end
    fast = performance_of do
      try_fast.search 'hello'
    end
    slow.should
    fast.should
    (slow / fast).should

    try_slow = Picky::Search.new index
    slow = performance_of do
      try_slow.search('hello hello').ids
    end
    try_fast = Picky::Search.new index do
      terminate_early
    end
    fast = performance_of do
      try_fast.search('hello hello').ids
    end
    slow.should
    fast.should
    (slow / fast).should

    try_slow = Picky::Search.new index
    slow = performance_of do
      try_slow.search('hello hello hello').ids
    end
    try_fast = Picky::Search.new index do
      terminate_early
    end
    fast = performance_of do
      try_fast.search('hello hello hello').ids
    end
    slow.should
    fast.should
    (slow / fast).should

    try_slow = Picky::Search.new index
    slow = performance_of do
      try_slow.search('hello hello hello hello').ids
    end
    try_fast = Picky::Search.new index do
      terminate_early
    end
    fast = performance_of do
      try_fast.search('hello hello hello hello').ids
    end
    slow.should
    fast.should
    (slow / fast).should >= 1.333
  end
end
