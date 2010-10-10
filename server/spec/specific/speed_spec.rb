require File.dirname(__FILE__) + '/../spec_helper'

describe "Speccing Ruby for speed" do
  describe "various versions for allocation id concatenating" do
    before(:each) do
      @allocs = [:hello, :speed, :test]
      @ids = {
        :hello => (1..100_000).to_a,
        :speed => (1..5_000).to_a,
        :test => (1..1_000).to_a
      }
      GC.disable
    end
    after(:each) do
      GC.enable
      GC.start # start the GC to minimize the chance that it will run again during the speed spec
    end
    describe "+" do
      it "should be fast" do
        Benchmark.realtime do
          @allocs.inject([]) do |total, alloc|
            total + @ids[alloc]
          end
        end.should < 0.0025
      end
    end
    describe "map and flatten!(1)" do
      it "should be fast" do
        Benchmark.realtime do
          @allocs.map { |alloc| @ids[alloc] }.flatten!(1)
        end.should < 0.02
      end
    end
    describe "<< and flatten!(1)" do
      it "should be fast" do
        Benchmark.realtime do
          @allocs.inject([]) do |total, alloc|
            total << @ids[alloc]
          end.flatten!(1)
        end.should < 0.02
      end
    end
    describe "<< and flatten!" do
      it "should be fast" do
        Benchmark.realtime do
          @allocs.inject([]) do |total, alloc|
            total << @ids[alloc]
          end.flatten!
        end.should < 0.02
      end
    end
  end
  
end