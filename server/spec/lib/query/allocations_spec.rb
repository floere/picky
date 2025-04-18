require 'spec_helper'

describe Picky::Query::Allocations do

  describe 'reduce_to' do
    before(:each) do
      @allocation1 = double :allocation1
      @allocation2 = double :allocation2
      @allocation3 = double :allocation3
      @allocations = described_class.new [@allocation1, @allocation2, @allocation3]
    end
    it 'should do nothing' do
      @allocations.reduce_to 2

      @allocations.to_a.should == [@allocation1, @allocation2]
    end
  end

  describe 'remove' do
    before(:each) do
      @allocation1 = double :allocation1
      @allocation2 = double :allocation2
      @allocation3 = double :allocation3
      @allocations = described_class.new [@allocation1, @allocation2, @allocation3]
    end
    context 'identifiers empty' do
      it 'should do nothing' do
        @allocation1.should_receive(:remove).never
        @allocation2.should_receive(:remove).never

        @allocations.remove_categories
      end
    end
    context 'categories not empty' do
      it 'should remove each' do
        @allocation1.should_receive(:remove).once.with :some_category
        @allocation2.should_receive(:remove).once.with :some_category
        @allocation3.should_receive(:remove).once.with :some_category

        @allocations.remove_categories :some_category
      end
    end
  end

  describe 'ids' do
    context 'integers' do
      before(:each) do
        @allocation1 = double :allocation1, ids: [1, 2, 3, 4]
        @allocation2 = double :allocation2, ids: [5, 6, 7]
        @allocation3 = double :allocation3, ids: [8, 9]
        @allocations = described_class.new [@allocation1, @allocation2, @allocation3]
      end
      it 'should return the right amount of ids' do
        @allocations.ids(0).should == []
      end
      it 'should return the right amount of ids' do
        @allocations.ids(6).should == [1, 2, 3, 4, 5, 6]
      end
      it 'should return the right amount of ids' do
        @allocations.ids.should == [1, 2, 3, 4, 5, 6, 7, 8, 9]
      end
    end
    context 'symbols' do
      before(:each) do
        @allocation1 = double :allocation1, ids: [:a, :b, :c, :d]
        @allocation2 = double :allocation2, ids: [:e, :f, :g]
        @allocation3 = double :allocation3, ids: [:h, :i]
        @allocations = described_class.new [@allocation1, @allocation2, @allocation3]
      end
      it 'should return the right amount of ids' do
        @allocations.ids(0).should == []
      end
      it 'should return the right amount of ids' do
        @allocations.ids(6).should == [:a, :b, :c, :d, :e, :f]
      end
      it 'should return the right amount of ids' do
        @allocations.ids.should == [:a, :b, :c, :d, :e, :f, :g, :h, :i]
      end
    end
  end

  describe 'process!' do
    before(:each) do
      @allocation1 = double :allocation1, count: 4, ids: [1, 2, 3, 4], empty_array: [] # TODO Why is empty_array necessary?
      @allocation2 = double :allocation2, count: 3, ids: [5, 6, 7]
      @allocation3 = double :allocation3, count: 2, ids: [8, 9]
      @allocations = described_class.new [@allocation1, @allocation2, @allocation3]
    end
    describe 'lazy evaluation' do
      context 'small amount' do
        before(:each) do
          @amount = 5
          @offset = 1
        end
        it 'should call the process! method right' do
          @allocation1.should_receive(:process!).once.with(5, 1, nil).and_return [2, 3, 4]
          @allocation2.should_receive(:process!).once.with(2, 0, nil).and_return [5, 6]
          @allocation3.should_receive(:process!).never

          @allocations.process! @amount, @offset, 0
        end
        it 'should call the process! method right including unique' do
          @allocation1.should_receive(:process_with_illegals!).once.with(5, 0, [], nil).and_return [2, 3, 4]
          @allocation2.should_receive(:process_with_illegals!).once.with(2, 0, [2, 3, 4], nil).and_return [5, 6]
          @allocation3.should_receive(:process_with_illegals!).never

          @allocations.process_unique! @amount, @offset, 0
        end
      end
      context 'larger amount' do
        before(:each) do
          @amount = 1
          @offset = 0
        end
        it 'should call the process! method right' do
          @allocation1.should_receive(:process!).once.with(1, 0, nil).and_return [1]
          @allocation2.should_receive(:process!).never
          @allocation3.should_receive(:process!).never

          @allocations.process! @amount, @offset, 0
        end
      end
      context 'small amount and early 1' do
        before(:each) do
          @amount = 5
          @offset = 1
        end
        it 'should call the process! method right' do
          @allocation1.should_receive(:process!).once.with(5, 1, nil).and_return [2, 3, 4]
          @allocation2.should_receive(:process!).once.with(2, 0, nil).and_return [5, 6]
          @allocation3.should_receive(:process!).once.with(0, 0, nil).and_return []

          @allocations.process! @amount, @offset, 1
        end
      end
      context 'larger amount and early 1' do
        before(:each) do
          @amount = 1
          @offset = 0
        end
        it 'should call the process! method right' do
          @allocation1.should_receive(:process!).once.with(1, 0, nil).and_return [1]
          @allocation2.should_receive(:process!).once.with(0, 0, nil).and_return []
          @allocation3.should_receive(:process!).never

          @allocations.process! @amount, @offset, 1
        end
      end
      context 'larger amount and early 0' do
        before(:each) do
          @amount = 4
          @offset = 0
        end
        it 'should call the process! method right' do
          @allocation1.should_receive(:process!).once.with(4, 0, nil).and_return [1, 2, 3, 4]
          @allocation2.should_receive(:process!).never
          @allocation3.should_receive(:process!).never

          @allocations.process! @amount, @offset, 0
        end
      end
      context 'larger amount and early 1' do
        before(:each) do
          @amount = 4
          @offset = 0
        end
        it 'should call the process! method right' do
          @allocation1.should_receive(:process!).once.with(4, 0, nil).and_return [1, 2, 3, 4]
          @allocation2.should_receive(:process!).once.with(0, 0, nil).and_return []
          @allocation3.should_receive(:process!).never

          @allocations.process! @amount, @offset, 1
        end
      end
      context 'larger amount and early 0' do
        before(:each) do
          @amount = 5
          @offset = 0
        end
        it 'should call the process! method right' do
          @allocation1.should_receive(:process!).once.with(5, 0, nil).and_return [1, 2, 3, 4]
          @allocation2.should_receive(:process!).once.with(1, 0, nil).and_return [5]
          @allocation3.should_receive(:process!).never

          @allocations.process! @amount, @offset, 0
        end
      end
      context 'larger amount and early 1' do
        before(:each) do
          @amount = 5
          @offset = 0
        end
        it 'should call the process! method right' do
          @allocation1.should_receive(:process!).once.with(5, 0, nil).and_return [1, 2, 3, 4]
          @allocation2.should_receive(:process!).once.with(1, 0, nil).and_return [5]
          @allocation3.should_receive(:process!).once.with(0, 0, nil).and_return []

          @allocations.process! @amount, @offset, 1
        end
      end
      context 'larger amount and early 1' do
        before(:each) do
          @amount = 8
          @offset = 0
        end
        it 'should call the process! method right' do
          @allocation1.should_receive(:process!).once.with(8, 0, nil).and_return [1, 2, 3, 4]
          @allocation2.should_receive(:process!).once.with(4, 0, nil).and_return [5, 6, 7]
          @allocation3.should_receive(:process!).once.with(1, 0, nil).and_return [8]

          @allocations.process! @amount, @offset, 1
        end
      end
    end
    describe 'amount spanning 3 allocations' do
      before(:each) do
        @amount = 6
        @offset = 2
      end
      it 'should call the process! method right' do
        @allocation1.should_receive(:process!).once.with(6, 2, nil).and_return [3, 4]
        @allocation2.should_receive(:process!).once.with(4, 0, nil).and_return [5, 6, 7]
        @allocation3.should_receive(:process!).once.with(1, 0, nil).and_return [8]

        @allocations.process! @amount, @offset
      end
    end
    describe 'large offset' do
      before(:each) do
        @amount = 10
        @offset = 8
      end
      it 'should call the process! method right' do
        @allocation1.should_receive(:process!).once.with(10, 8, nil).and_return []
        @allocation2.should_receive(:process!).once.with(10, 4, nil).and_return []
        @allocation3.should_receive(:process!).once.with(10, 1, nil).and_return [9]

        @allocations.process! @amount, @offset
      end
    end
    context 'amount 0' do
      before(:each) do
        @amount = 0
      end
      it 'should return an empty array always' do
        @allocation1.should_receive(:process!).once.with(0, 0, nil).and_return []
        @allocation2.should_receive(:process!).once.with(0, 0, nil).and_return []
        @allocation3.should_receive(:process!).once.with(0, 0, nil).and_return []

        @allocations.process! @amount
      end
    end
    context 'amount > 0' do
      before(:each) do
        @amount = 3
      end
      context 'offset 0' do
        before(:each) do
          @offset = 0
        end
        it 'should return certain ids' do
          @allocation1.should_receive(:process!).once.with(3, 0, nil).and_return [1, 2, 3]
          @allocation2.should_receive(:process!).once.with(0, 0, nil).and_return []
          @allocation3.should_receive(:process!).once.with(0, 0, nil).and_return []

          @allocations.process! @amount, @offset
        end
      end
      context 'offset 3' do
        before(:each) do
          @offset = 3
        end
        it 'should return certain ids' do
          @allocation1.should_receive(:process!).once.with(3, 3, nil).and_return [4]
          @allocation2.should_receive(:process!).once.with(2, 0, nil).and_return [5, 6]
          @allocation3.should_receive(:process!).once.with(0, 0, nil).and_return []

          @allocations.process! @amount, @offset
        end
      end
    end
  end

  describe 'to_result' do
    context 'all allocations have results' do
      before(:each) do
        @allocation = double :allocation
        @allocations = described_class.new [@allocation, @allocation, @allocation]
      end
      it 'should forward to each allocation with no params' do
        @allocation.should_receive(:to_result).exactly(3).times.with no_args

        @allocations.to_result
      end
    end
    context 'one allocation has no results' do
      before(:each) do
        @allocation           = double :allocation, to_result: :some_result
        @no_result_allocation = double :no_results, to_result: nil
        @allocations = described_class.new [@allocation, @no_result_allocation, @allocation]
      end
      it 'should forward to each allocation with the same params' do
        @allocations.to_result.should == [:some_result, :some_result]
      end
    end
  end

  describe 'total' do
    context 'with allocations' do
      before(:each) do
        @allocations = described_class.new [
          double(:allocation, process!: (1..10).to_a, count: 10),
          double(:allocation, process!: (1..80).to_a, count: 80),
          double(:allocation, process!: (1..20).to_a, count: 20)
        ]
      end
      it 'should traverse the allocations and sum the counts' do
        @allocations.process! 20, 0

        @allocations.total.should == 110
      end
    end
    context 'without allocations' do
      before(:each) do
        @allocations = described_class.new []
      end
      it 'should be 0' do
        @allocations.process! 20, 0

        @allocations.total.should == 0
      end
    end
  end

  describe 'each' do
    before(:each) do
      @internal_allocations = double :internal_allocations
      @allocations = described_class.new @internal_allocations
    end
    it 'should forward to the internal allocations' do
      stub_proc = lambda {}
      @internal_allocations.should_receive(:each).once.with no_args, &stub_proc

      @allocations.each &stub_proc
    end
  end
  describe 'inject' do
    before(:each) do
      @internal_allocations = double :internal_allocations
      @allocations = described_class.new @internal_allocations
    end
    it 'should forward to the internal allocations' do
      stub_proc = lambda {}
      @internal_allocations.should_receive(:inject).once.with no_args, &stub_proc

      @allocations.inject &stub_proc
    end
  end
  describe 'empty?' do
    before(:each) do
      @internal_allocations = double :internal_allocations
      @allocations = described_class.new @internal_allocations
    end
    it 'should forward to the internal allocations array' do
      @internal_allocations.should_receive(:empty?).once
      @allocations.empty?
    end
  end

  describe 'to_s' do
    before(:each) do
      @allocation           = double :allocation, to_result: :some_result
      @no_result_allocation = double :no_results, to_result: nil
      @allocations = described_class.new [@allocation, @no_result_allocation, @allocation]
    end
    it 'should forward to the internal allocations array' do
      @allocations.to_s.should == '[:some_result, :some_result]'
    end
  end

  describe 'process!' do
    context 'some allocations' do
      before(:each) do
        @allocations = described_class.new [
          double(:allocation, process!: (1..10).to_a, count: 10),
          double(:allocation, process!: (1..80).to_a, count: 80),
          double(:allocation, process!: (1..20).to_a, count: 20)
        ]
      end
      it 'should calculate the right total' do
        @allocations.process! 20, 0

        @allocations.total.should == 110
      end
      it 'should be fast' do
        performance_of { @allocations.process!(20, 0) }.should < 0.0001
      end
    end
  end

end
