require 'spec_helper'

describe Internals::Results::Base do
  
  describe "from" do
    before(:each) do
      @results = stub :results
      described_class.stub! :new => @results
      
      @results.stub! :prepare!
    end
    it "should generate a result" do
      described_class.from(0, @allocations).should == @results
    end
  end
  
  describe "ids" do
    before(:each) do
      @allocations = stub :allocations
      @results = described_class.new :unimportant, @allocations
    end
    it "delegates" do
      @allocations.should_receive(:ids).once.with :anything
      
      @results.ids :anything
    end
  end
  
  describe 'to_log' do
    before(:each) do
      time = stub :time, :to_s => '0-08-16 10:07:33'
      Time.stub! :now => time
    end
    context 'without results' do
      before(:each) do
        @results = described_class.new
      end
      it 'should output a default log' do
        @results.to_log('some_query').should == '|0-08-16 10:07:33|0.000000|some_query                                        |       0|   0| 0|'
      end
    end
    context 'with results' do
      before(:each) do
        @allocations = stub :allocations,
                            :process! => nil, :size => 12

        @results = described_class.new 1234, @allocations
        @results.stub! :duration => 0.1234567890,
                       :total    => 12345678
      end
      it 'should output a specific log' do
        @results.to_log('some_query').should == '|0-08-16 10:07:33|0.123457|some_query                                        |12345678|1234|12|'
      end
    end
  end

  describe 'to_json' do
    before(:each) do
      @results = described_class.new
    end
    it 'should do it correctly' do
      @results.stub! :serialize => :serialized

      @results.to_json.should == '"serialized"'
    end
  end

  describe 'serialize' do
    before(:each) do
      @allocations = stub :allocations, :process! => nil, :to_result => :allocations, :total => :some_total

      @results = described_class.new :some_offset, @allocations
      @results.duration = :some_duration
    end
    it 'should do it correctly' do
      @results.prepare!

      @results.serialize.should == { :allocations => :allocations, :offset => :some_offset, :duration => :some_duration, :total => :some_total }
    end
  end

  describe "accessors" do
    before(:each) do
      @results = described_class.new :anything
      @some_stub = stub(:some)
    end
    it "should have accessors for duration" do
      @results.duration = @some_stub
      @results.duration.should == @some_stub
    end
  end

end