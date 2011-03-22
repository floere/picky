# coding: utf-8
#
require 'spec_helper'

describe Internals::Query::Combinations::Memory do

  before(:each) do
    @combinations_ary = stub :combinations_ary
    
    @combinations = described_class.new @combinations_ary
  end
  
  describe "to_result" do
    before(:each) do
      @combination1 = stub :combination1, :to_result => :result1
      @combination2 = stub :combination2, :to_result => :result2
      
      @combinations_ary = [@combination1, @combination2]
      
      @combinations = described_class.new @combinations_ary
    end
    it "resultifies the combinations" do
      @combinations.to_result.should == [:result1, :result2]
    end
  end
  
  describe "weighted_score" do
    it "uses the weights' score method" do
      weights = stub :weights
      weights.should_receive(:score).once.with @combinations_ary
      
      @combinations.weighted_score weights
    end
  end
  
  describe "total_score" do
    before(:each) do
      @combination1 = stub :combination1, :weight => 3.14
      @combination2 = stub :combination2, :weight => 2.76
      
      @combinations_ary = [@combination1, @combination2]
      
      @combinations = described_class.new @combinations_ary
    end
    it "sums the scores" do
      @combinations.total_score.should == 5.90
    end
  end
  
  describe "calculate_score" do
    before(:each) do
      @combinations.stub! :total_score => 0
      @combinations.stub! :weighted_score => 0
    end
    it "first sums, then weighs" do
      @combinations.should_receive(:total_score).once.ordered.and_return 0
      @combinations.should_receive(:weighted_score).once.ordered.and_return 0
      
      @combinations.calculate_score :anything
    end
    it "calls sum_score" do
      @combinations.should_receive(:total_score).once.with.and_return 0
      
      @combinations.calculate_score :anything
    end
    it "calls sum_score" do
      @combinations.should_receive(:weighted_score).once.with(:weights).and_return 0
      
      @combinations.calculate_score :weights
    end
  end
  
  describe 'hash' do
    it "delegates to the combinations array" do
      @combinations_ary.should_receive(:hash).once.with
      
      @combinations.hash
    end
  end
  
  describe 'remove' do
    before(:each) do
      @combination1 = stub :combination1, :in? => false
      @combination2 = stub :combination2, :in? => true
      @combination3 = stub :combination3, :in? => true

      @combinations = described_class.new [@combination1, @combination2, @combination3]
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

      @combinations = described_class.new [@combination1, @combination2, @combination3]
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
      @combinations = described_class.new [@combination1, @combination2, @combination3]
    end
    it "should intersect correctly" do
      @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
      @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      @combinations.ids(:any, :thing).should == (1..10).to_a
    end
    it "should intersect symbol_keys correctly" do
      @combination1.should_receive(:ids).once.with.and_return (:'00001'..:'10000').to_a
      @combination2.should_receive(:ids).once.with.and_return (:'00001'..:'00100').to_a
      @combination3.should_receive(:ids).once.with.and_return (:'00001'..:'00010').to_a

      @combinations.ids(:any, :thing).should == (:'00001'..:'0010').to_a
    end
    it "should intersect correctly when intermediate intersect result is empty" do
      @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
      @combination2.should_receive(:ids).once.with.and_return (11..100).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      @combinations.ids(:any, :thing).should == []
    end
    it "should be fast" do
      @combination1.should_receive(:ids).once.with.and_return (1..100_000).to_a
      @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      performance_of { @combinations.ids(:any, :thing) }.should < 0.004
    end
    it "should be fast" do
      @combination1.should_receive(:ids).once.with.and_return (1..1000).to_a
      @combination2.should_receive(:ids).once.with.and_return (1..100).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      performance_of { @combinations.ids(:any, :thing) }.should < 0.00015
    end
    it "should be fast" do
      @combination1.should_receive(:ids).once.with.and_return (1..1000).to_a
      @combination2.should_receive(:ids).once.with.and_return (901..1000).to_a
      @combination3.should_receive(:ids).once.with.and_return (1..10).to_a

      performance_of { @combinations.ids(:any, :thing) }.should < 0.0001
    end
  end

end