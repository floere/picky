require 'spec_helper'

describe Query::Weights do

  before(:each) do
    @weights = Query::Weights.new [:test1, :test2]         => 6,
                                     [:test1]                 => 5,
                                     [:test3]                 => 3,
                                     [:test3, :test2]         => 4,
                                     [:test1, :test4]         => 5,
                                     [:test4, :test1]         => 5,
                                     [:test4, :test1, :test2] => 4,
                                     [:test1, :test4, :test2] => 4,
                                     [:test4, :test5]         => 3,
                                     [:test5, :test1]         => 2,
                                     [:test1, :test5]         => 2,
                                     [:test3, :test1]         => 2,
                                     [:test1, :test3]         => 2
  end

  describe "weight_for" do
    it "should return zero if there is no specific weight" do
      @weights.weight_for([:not_a_specific_allocation]).should be_zero
    end
  end
  
  def self.it_should_return_a_specific_weight_for(allocation, weight)
    it "should return weight #{weight} for #{allocation.inspect}" do
      @weights.weight_for(allocation).should == weight
    end
  end
  
  it_should_return_a_specific_weight_for [:test1, :test2],         6
  it_should_return_a_specific_weight_for [:test1],                 5
  it_should_return_a_specific_weight_for [:test1, :test3],         2
  it_should_return_a_specific_weight_for [:test3],                 3
  it_should_return_a_specific_weight_for [:test3, :test2],         4
  it_should_return_a_specific_weight_for [:test1, :test4],         5
  it_should_return_a_specific_weight_for [:test4, :test1],         5
  it_should_return_a_specific_weight_for [:test4, :test1, :test2], 4
  it_should_return_a_specific_weight_for [:test1, :test4, :test2], 4
  it_should_return_a_specific_weight_for [:test4, :test5],         3
  it_should_return_a_specific_weight_for [:test5, :test1],         2
  it_should_return_a_specific_weight_for [:test1, :test5],         2
  it_should_return_a_specific_weight_for [:test3, :test1],         2
  
end