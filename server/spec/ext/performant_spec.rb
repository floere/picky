require File.dirname(__FILE__) + '/../spec_helper'

describe Performant::Array do

  describe "memory_efficient_intersect" do
    before(:each) do
      GC.disable
    end
    after(:each) do
      GC.enable
      GC.start
    end
    it "should intersect empty arrays correctly" do
      arys = [[3,4], [1,2,3], []]

      Performant::Array.memory_efficient_intersect(arys.sort_by(&:size)).should == []
    end
    it "should handle intermediate empty results correctly" do
      arys = [[5,4], [1,2,3], [3,4,5,8,9]]

      Performant::Array.memory_efficient_intersect(arys.sort_by(&:size)).should == []
    end
    it "should intersect correctly" do
      arys = [[3,4], [1,2,3], [3,4,5,8,9]]

      Performant::Array.memory_efficient_intersect(arys.sort_by(&:size)).should == [3]
    end
    it "should intersect correctly again" do
      arys = [[3,4,5,6,7], [1,2,3,5,6,7], [3,4,5,6,7,8,9]]

      Performant::Array.memory_efficient_intersect(arys.sort_by(&:size)).should == [3,5,6,7]
    end
    it "should intersect many arrays" do
      arys = [[3,4,5,6,7], [1,2,3,5,6,7], [3,4,5,6,7,8,9], [1,2,3,4,5,6,7,8,9,10], [2,3,5,6,7,19], [1,2,3,4,5,6,7,8,9,10], [2,3,5,6,7,19]]

      Performant::Array.memory_efficient_intersect(arys.sort_by(&:size)).should == [3,5,6,7]
    end
    it "should handle random arrays" do
      proto = Array.new(100, 3_500_000)
      arys = [proto.map { |e| rand e }, proto.map { |e| rand e }, proto.map { |e| rand e }]

      Performant::Array.memory_efficient_intersect(arys.sort_by(&:size)).should == arys.inject(arys.shift.dup) { |total, ary| total & arys }
    end
    it "should be optimal for 2 small arrays of 50/10_000" do
      arys = [(1..50).to_a, (10_000..20_000).to_a << 7]

      # brute force
      Benchmark.realtime do
        Performant::Array.memory_efficient_intersect(arys.sort_by(&:size))
      end.should <= 0.001
    end
    it "should be optimal for 2 small arrays of 50/10_000" do
      arys = [(1..50).to_a, (10_000..20_000).to_a << 7]

      # &
      Benchmark.realtime do
        arys.inject(arys.shift.dup) do |total, ary|
          total & arys
        end
      end.should <= 0.0015
    end
  end

end