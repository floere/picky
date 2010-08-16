# coding: utf-8
#
require 'spec_helper'

describe 'Query::Combinations' do

  before(:each) do
    @combinations_ary = stub :combinations_ary

    @combinations = Query::Combinations.new :some_type, @combinations_ary
  end

  describe 'remove' do
    before(:each) do
      @combination1 = stub :combination1, :in? => false
      @combination2 = stub :combination2, :in? => true
      @combination3 = stub :combination3, :in? => true

      @combinations = Query::Combinations.new :some_type, [@combination1, @combination2, @combination3]
    end
    it 'should remove the combinations' do
      @combinations.remove([:any]).should == [@combination1]
    end
  end

  describe 'keep' do
    before(:each) do
      @combination1 = stub :combination1, :in? => false
      @combination2 = stub :combination2, :in? => true
      @combination3 = stub :combination3, :in? => true

      @combinations = Query::Combinations.new :some_type, [@combination1, @combination2, @combination3]
    end
    it 'should filter the combinations' do
      @combinations.keep([:any]).should == [@combination2, @combination3]
    end
  end

  describe "ids" do
    before(:each) do
      @combination1 = stub :combination1
      @combination2 = stub :combination2
      @combination3 = stub :combination3
      @combinations = Query::Combinations.new :some_type, [@combination1, @combination2, @combination3]
    end
    it "should intersect correctly" do
      @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
      @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      @combinations.ids.should == (1..10).to_a
    end
    it "should intersect correctly when intermediate intersect result is empty" do
      @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
      @combination2.should_receive(:ids).once.with.and_return (11..100).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      @combinations.ids.should == []
    end
    it "should be fast" do
      @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
      @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      Benchmark.realtime { @combinations.ids }.should <= 0.004
    end
    it "should be fast" do
      @combination1.should_receive(:ids).once.with.and_return (1..1000).to_a
      @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      Benchmark.realtime { @combinations.ids }.should <= 0.00015
    end
    it "should be fast" do
      @combination1.should_receive(:ids).once.with.and_return (1..1000).to_a
      @combination2.should_receive(:ids).once.with.and_return (901..1000).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      Benchmark.realtime { @combinations.ids }.should <= 0.0001
    end
  end

end