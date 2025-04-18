require 'spec_helper'

describe Picky::Results do

  describe 'ids' do
    before(:each) do
      @allocations = double :allocations
      @results = described_class.new :unimportant, :amount, :offset, @allocations
    end
    it 'forwards' do
      @allocations.should_receive(:process!).once.with :amount, :offset, nil, nil
      @allocations.should_receive(:ids).once.with :anything

      @results.ids :anything
    end
    it 'forwards and uses amount if nothing given' do
      @allocations.should_receive(:process!).once.with :amount, :offset, nil, nil
      @allocations.should_receive(:ids).once.with :amount

      @results.ids
    end
  end

  describe 'to_s time format' do
    it 'is in the right format' do
      described_class.new('some_query').to_s.should match(/\d{2}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
    end
  end

  describe 'to_s' do
    before(:each) do
      time = double :time, strftime: '2011-08-16 10:07:33'
      Time.stub now: time
    end
    context 'without results' do
      before(:each) do
        @results = described_class.new 'some_query'
      end
      it 'should output a default log' do
        @results.to_s.should == '.|2011-08-16 10:07:33|0.000000|some_query                                        |       0|   0| 0|'
      end
    end
    context 'with results' do
      before(:each) do
        @allocations = double :allocations,
                              process!: nil,
                              size: 12

        @results = described_class.new 'some_query', 20, 1234, @allocations
        @results.stub duration: 0.1234567890,
                      total: 12345678
      end
      it 'should output a specific log' do
        @results.to_s.should == '>|2011-08-16 10:07:33|0.123457|some_query                                        |12345678|1234|12|'
      end
    end
  end

  describe 'to_json' do
    before(:each) do
      @results = described_class.new
    end
    it 'should do it correctly' do
      @results.stub to_hash: :serialized

      @results.to_json.should == '"serialized"'
    end
  end

  describe 'to_hash' do
    before(:each) do
      @allocations = double :allocations, process!: nil, to_result: :allocations, total: :some_total

      @results = described_class.new :unimportant, :some_results_amount, :some_offset, @allocations
      @results.duration = :some_duration
    end
    it 'should do it correctly' do
      @results.prepare!

      @results.to_hash.should == { allocations: :allocations, offset: :some_offset, duration: :some_duration, total: :some_total }
    end
  end

  describe 'accessors' do
    before(:each) do
      @allocations = double :allocations, process!: :allocations
      @results = described_class.new :query, :amount, :offset, @allocations
    end
    it 'should have accessors for query' do
      @results.query.should == :query
    end
    it 'should have accessors for amount' do
      @results.amount.should == :amount
    end
    it 'should have accessors for offset' do
      @results.offset.should == :offset
    end
    it 'should have accessors for allocations' do
      @results.allocations.should == @allocations
    end
    it 'should have accessors for duration' do
      @results.duration = :some_duration
      @results.duration.should == :some_duration
    end
  end

end