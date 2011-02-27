require 'spec_helper'

describe Query::Live do

  before(:each) do
    @indexed  = stub :indexed
    @index = stub :index, :indexed => @indexed
  end

  describe 'result_type' do
    before(:each) do
      @query = described_class.new @index
    end
    it "should return a specific type" do
      @query.result_type.should == Internals::Results::Live
    end
  end

  describe "execute" do
    before(:each) do
      @query = described_class.new @index
    end
    it "should get allocations" do
      @query.result_type.should_receive :from
      @query.should_receive(:sorted_allocations).once

      @query.execute 'some_query', 0
    end
  end

end