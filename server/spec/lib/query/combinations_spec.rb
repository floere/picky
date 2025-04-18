# coding: utf-8
#
require 'spec_helper'

describe Picky::Query::Combinations do

  before(:each) do
    @combinations_ary = double :combinations_ary

    @combinations = described_class.new @combinations_ary
  end

  describe "to_result" do
    before(:each) do
      @combination1 = double :combination1, to_result: :result1
      @combination2 = double :combination2, to_result: :result2

      @combinations_ary = [@combination1, @combination2]

      @combinations = described_class.new @combinations_ary
    end
    it "resultifies the combinations" do
      @combinations.to_result.should == [:result1, :result2]
    end
  end

  describe "total_score" do
    before(:each) do
      @combination1 = double :combination1, weight: 3.14
      @combination2 = double :combination2, weight: 2.76

      @combinations_ary = [@combination1, @combination2]

      @combinations = described_class.new @combinations_ary
    end
    it "sums the scores" do
      @combinations.score.should == 5.90
    end
  end

  # describe 'remove' do
  #   before(:each) do
  #     @combination1 = double :combination1, :category => double(:other, :name => :other)
  #     @combination2 = double :combination2, :category => double(:to_remove, :name => :to_remove)
  #     @combination3 = double :combination3, :category => double(:to_remove, :name => :to_remove)
  #
  #     @combinations = described_class.new [@combination1, @combination2, @combination3]
  #   end
  #   it 'should remove the combinations' do
  #     @combinations.remove([:to_remove]).should == [@combination1]
  #   end
  # end

end