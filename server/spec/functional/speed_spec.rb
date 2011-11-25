# encoding: utf-8
#
require File.dirname(__FILE__) + '/../spec_helper'

describe "Speccing Ruby for speed" do
  describe "various versions for allocation id concatenating – with symbols" do
    before(:each) do
      @allocs = [:hello, :speed, :test]
      @ids = {
        :hello => (:'000_001'..:'100_000').to_a,
        :speed => (:'0_001'..:'5_000').to_a,
        :test => (:'0_001'..:'1_000').to_a
      }
    end
    describe "+" do
      it "should be fast" do
        performance_of do
          @allocs.inject([]) do |total, alloc|
            total + @ids[alloc]
          end
        end.should < 0.0025
      end
    end
    describe "map and flatten!(1)" do
      it "should be fast" do
        performance_of do
          @allocs.map { |alloc| @ids[alloc] }.flatten!(1)
        end.should < 0.02
      end
    end
    describe "<< and flatten!(1)" do
      it "should be fast" do
        performance_of do
          @allocs.inject([]) do |total, alloc|
            total << @ids[alloc]
          end.flatten!(1)
        end.should < 0.02
      end
    end
    describe "<< and flatten!" do
      it "should be fast" do
        performance_of do
          @allocs.inject([]) do |total, alloc|
            total << @ids[alloc]
          end.flatten!
        end.should < 0.02
      end
    end
  end
  describe "various versions for allocation id concatenating – with integers" do
    before(:each) do
      @allocs = [:hello, :speed, :test]
      @ids = {
        :hello => (1..100_000).to_a,
        :speed => (1..5_000).to_a,
        :test => (1..1_000).to_a
      }
    end
    describe "+" do
      it "should be fast" do
        performance_of do
          @allocs.inject([]) do |total, alloc|
            total + @ids[alloc]
          end
        end.should < 0.0025
      end
    end
    describe "map and flatten!(1)" do
      it "should be fast" do
        performance_of do
          @allocs.map { |alloc| @ids[alloc] }.flatten!(1)
        end.should < 0.02
      end
    end
    describe "<< and flatten!(1)" do
      it "should be fast" do
        performance_of do
          @allocs.inject([]) do |total, alloc|
            total << @ids[alloc]
          end.flatten!(1)
        end.should < 0.02
      end
    end
    describe "<< and flatten!" do
      it "should be fast" do
        performance_of do
          @allocs.inject([]) do |total, alloc|
            total << @ids[alloc]
          end.flatten!
        end.should < 0.02
      end
    end
  end
  
end