require 'spec_helper'

describe Query::Live do

  before(:each) do
    @indexed  = stub :indexed
    @index = stub :index, :indexed => @indexed
  end

  describe 'result_type' do
    before(:each) do
      @query = Query::Live.new @index
    end
    it "should return a specific type" do
      @query.result_type.should == Results::Live
    end
  end

  describe "execute" do
    before(:each) do
      @query = Query::Live.new @index
    end
    it "should get allocations" do
      @query.should_receive(:results_from).and_return stub(:results, :prepare! => true)
      @query.should_receive(:sorted_allocations).once

      @query.execute 'some_query', 0
    end
    it "should generate a max amount of results from allocations" do
      allocations = stub :allocations
      @query.should_receive(:sorted_allocations).and_return allocations

      @query.should_receive(:results_from).once.with(0, allocations).and_return stub(:results, :prepare! => true)

      @query.execute 'some query', 0
    end
  end

  describe "results_from" do
    describe "with empty ids" do
      before(:each) do
        @query = Query::Live.new @index
        @allocations = stub :allocations, :total => 0, :ids => [], :to_result => :some_results, :process! => nil
      end
      it "should generate a result" do
        @query.results_from(@allocations).should be_kind_of Results::Live
      end
      it "should generate a result with 0 result count" do
        @query.results_from(@allocations).total.should == 0
      end
      it "should generate a result with 0 duration" do
        @query.results_from(@allocations).duration.should == 0
      end
      it "should generate a result with the allocations" do
        @query.results_from(0, @allocations).allocations.should == @allocations
      end
    end
  end

end