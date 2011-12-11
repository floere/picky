require 'spec_helper'

describe Picky::Results do

  describe "from" do
    before(:each) do
      @results = stub :results
      described_class.stub! :new => @results

      @results.stub! :prepare!
    end
    it "should generate a result" do
      described_class.from("some query", 20, 0, @allocations).should == @results
    end
  end

  describe "ids" do
    before(:each) do
      @allocations = stub :allocations
      @results = described_class.new :unimportant, :unimportant, :unimportant, @allocations
    end
    it "delegates" do
      @allocations.should_receive(:ids).once.with :anything

      @results.ids :anything
    end
  end

  describe 'to_s' do
    before(:each) do
      time = stub :time, :to_s => '0-08-16 10:07:33'
      Time.stub! :now => time
    end
    context 'without results' do
      before(:each) do
        @results = described_class.new "some_query"
      end
      it 'should output a default log' do
        @results.to_s.should == '.|0-08-16 10:07:33|0.000000|some_query                                        |       0|   0| 0|'
      end
    end
    context 'with results' do
      before(:each) do
        @allocations = stub :allocations,
                            :process! => nil,
                            :size => 12

        @results = described_class.new "some_query", 20, 1234, @allocations
        @results.stub! :duration => 0.1234567890,
                       :total    => 12345678
      end
      it 'should output a specific log' do
        @results.to_s.should == '>|0-08-16 10:07:33|0.123457|some_query                                        |12345678|1234|12|'
      end
    end
  end

  describe 'to_json' do
    before(:each) do
      @results = described_class.new
    end
    it 'should do it correctly' do
      @results.stub! :to_hash => :serialized

      @results.to_json.should == '"serialized"'
    end
  end

  describe 'to_hash' do
    before(:each) do
      @allocations = stub :allocations, :process! => nil, :to_result => :allocations, :total => :some_total

      @results = described_class.new :unimportant, :some_results_amount, :some_offset, @allocations
      @results.duration = :some_duration
    end
    it 'should do it correctly' do
      @results.prepare!

      @results.to_hash.should == { :allocations => :allocations, :offset => :some_offset, :duration => :some_duration, :total => :some_total }
    end
  end

  describe "accessors" do
    before(:each) do
      @results = described_class.new :query, :amount, :offset, :allocations
    end
    it "should have accessors for query" do
      @results.query.should == :query
    end
    it "should have accessors for amount" do
      @results.amount.should == :amount
    end
    it "should have accessors for offset" do
      @results.offset.should == :offset
    end
    it "should have accessors for allocations" do
      @results.allocations.should == :allocations
    end
    it "should have accessors for duration" do
      @results.duration = :some_duration
      @results.duration.should == :some_duration
    end
  end

end