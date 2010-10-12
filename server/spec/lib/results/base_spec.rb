require 'spec_helper'

describe Results do
  
  describe 'to_log' do
    before(:each) do
      time = stub :time, :to_s => '0-08-16 10:07:33'
      Time.stub! :now => time
    end
    context 'without results' do
      before(:each) do
        @results = Results::Base.new
      end
      it 'should output a default log' do
        @results.to_log('some_query').should == '|0-08-16 10:07:33|0.000000|some_query                                        |       0|   0| 0|'
      end
    end
    context 'with results' do
      before(:each) do
        @allocations = stub :allocations,
                            :process! => nil, :size => 12

        @results = Results::Base.new @allocations
        @results.stub! :duration => 0.1234567890,
                       :total    => 12345678,
                       :offset   => 1234
      end
      it 'should output a specific log' do
        @results.to_log('some_query').should == '|0-08-16 10:07:33|0.123457|some_query                                        |12345678|1234|12|'
      end
    end
  end

  describe 'to_json' do
    before(:each) do
      @results = Results::Base.new
    end
    it 'should do it correctly' do
      @results.stub! :serialize => :serialized

      @results.to_json.should == '"serialized"'
    end
  end

  describe 'serialize' do
    before(:each) do
      @allocations = stub :allocations, :process! => nil, :to_result => :allocations, :total => :some_total

      @results = Results::Base.new @allocations
      @results.duration = :some_duration
    end
    it 'should do it correctly' do
      @results.prepare! :some_offset

      @results.serialize.should == { :allocations => :allocations, :offset => :some_offset, :duration => :some_duration, :total => :some_total }
    end
  end

  describe 'prepare!' do
    describe 'Full' do
      before(:each) do
        @results = Results::Full.new
        @allocations = stub :allocations
        @results.stub! :allocations => @allocations
      end
      it 'should process' do
        @allocations.should_receive(:process!).once.with(20, 0).ordered
        
        @results.prepare!
      end
    end
    describe 'Live' do
      before(:each) do
        @results = Results::Live.new
        @allocations = stub :allocations
        @results.stub! :allocations => @allocations
      end
      it 'should generate truncate the ids fully' do
        @allocations.should_receive(:process!).once.with(0, 0).ordered

        @results.prepare!
      end
    end
  end

  describe "class accessors" do
    describe 'Full' do
      it "should have accessors for max_results" do
        max_results = stub :max_results
        old_results = Results::Full.max_results
        Results::Full.max_results = max_results

        Results::Full.max_results.should == max_results

        Results::Full.max_results = old_results
      end
    end
    describe 'Live' do
      it "should have accessors for max_results" do
        max_results = stub :max_results
        old_results = Results::Live.max_results
        Results::Live.max_results = max_results

        Results::Live.max_results.should == max_results

        Results::Live.max_results = old_results
      end
    end
  end

  describe 'initialize' do
    context 'without allocations' do
      describe 'Full' do
        it 'should not fail' do
          lambda {
            Results::Full.new
          }.should_not raise_error
        end
        it 'should set the allocations to allocations that are empty' do
          Results::Full.new.instance_variable_get(:@allocations).should be_empty
        end
      end
      describe 'Live' do
        it 'should not fail' do
          lambda {
            Results::Live.new
          }.should_not raise_error
        end
        it 'should set the allocations to allocations that are empty' do
          Results::Live.new.instance_variable_get(:@allocations).should be_empty
        end
      end
    end
    context 'with allocations' do
      describe 'Full' do
        it 'should not fail' do
          lambda {
            Results::Full.new :some_allocations
          }.should_not raise_error
        end
        it 'should set the allocations to an empty array' do
          Results::Full.new(:some_allocations).instance_variable_get(:@allocations).should == :some_allocations
        end
      end
      describe 'Live' do
        it 'should not fail' do
          lambda {
            Results::Live.new :some_allocations
          }.should_not raise_error
        end
        it 'should set the allocations to an empty array' do
          Results::Live.new(:some_allocations).instance_variable_get(:@allocations).should == :some_allocations
        end
      end
    end
  end

  describe 'duration' do
    describe 'Full' do
      before(:each) do
        @results = Results::Full.new
      end
      it 'should return the set duration' do
        @results.duration = :some_duration

        @results.duration.should == :some_duration
      end
      it 'should return 0 as a default' do
        @results.duration.should == 0
      end
    end
    describe 'Live' do
      before(:each) do
        @results = Results::Live.new
      end
      it 'should return the set duration' do
        @results.duration = :some_duration

        @results.duration.should == :some_duration
      end
      it 'should return 0 as a default' do
        @results.duration.should == 0
      end
    end
  end

  describe 'total' do
    describe 'Full' do
      it 'should delegate to allocations.total' do
        allocations = stub :allocations
        results = Results::Full.new allocations

        allocations.should_receive(:total).once

        results.total
      end
    end
    describe 'Live' do
      it 'should delegate to allocations.total' do
        allocations = stub :allocations
        results = Results::Live.new allocations

        allocations.should_receive(:total).once

        results.total
      end
    end

  end

  describe "accessors" do
    before(:each) do
      @results = Results::Base.new :anything
      @some_stub = stub(:some)
    end
    it "should have accessors for duration" do
      @results.duration = @some_stub
      @results.duration.should == @some_stub
    end
  end

end