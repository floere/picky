require 'spec_helper'

describe Array do
  describe 'sort_by_levenshtein!' do
    it 'should sort right' do
      %w[fish flash flush smooch].sort_by_levenshtein!(:fush).should == %w[fish flush flash smooch]
    end
  end

  describe 'clustered_uniq' do
    it 'should generate a new array' do
      ary = %i[test1 test2 test1]
      ary.clustered_uniq.object_id.should_not == ary.object_id
    end
    it 'should not change clusteredly unique arrays' do
      %i[test1 test2 test1].clustered_uniq.should == %i[test1 test2 test1]
    end
    it 'should not skip interspersed elements' do
      %i[test1 test1 test2 test1].clustered_uniq.should == %i[test1 test2 test1]
    end
    it 'should work like uniq if no interspersed elements exist' do
      %i[test1 test1 test2 test2 test3].clustered_uniq.should == %i[test1 test2 test3]
    end
    it 'is fast' do
      performance_of { %i[test1 test1 test2 test2 test3].clustered_uniq }.should < 0.00001
    end
  end
  # describe "clustered_uniq" do
  #   it "should generate a new array" do
  #     ary = [:test1, :test2, :test1]
  #     ary.clustered_uniq.object_id.should_not == ary.object_id
  #   end
  #   it "should not change clusteredly unique arrays" do
  #     [:test1, :test2, :test1].clustered_uniq.should == [:test1, :test2, :test1]
  #   end
  #   it "should not skip interspersed elements" do
  #     [:test1, :test1, :test2, :test1].clustered_uniq.should == [:test1, :test2, :test1]
  #   end
  #   it "should work like uniq if no interspersed elements exist" do
  #     [:test1, :test1, :test2, :test2, :test3].clustered_uniq.should == [:test1, :test2, :test3]
  #   end
  #   it "is fast" do
  #     performance_of { [:test1, :test1, :test2, :test2, :test3].clustered_uniq }.should < 0.000012
  #   end
  # end
end
