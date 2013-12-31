require 'spec_helper'

describe Picky::Query::Allocation do

  before(:each) do
    @backend      = double :backend
    @index        = double :index, :result_identifier => :some_result_identifier, :backend => @backend
    @combinations = double :combinations, :empty? => false
    @allocation   = described_class.new @index, @combinations
  end

  describe "to_s" do
    before(:each) do
      @combinations.stub :to_result => 'combinations_result'
    end
    context "allocation.count > 0" do
      before(:each) do
        @allocation.stub :count => 10
        @allocation.stub :score => :score
        @allocation.stub :ids => :ids
      end
      it "represents correctly" do
        @allocation.to_s.should == "Allocation([:some_result_identifier, :score, 10, \"combinations_result\", :ids])"
      end
    end
  end

  describe 'remove' do
    it 'should forward to the combinations' do
      @combinations.should_receive(:remove).once.with [:some_categories]

      @allocation.remove [:some_categories]
    end
  end

  describe 'process!' do
    context 'no ids' do
      before(:each) do
        @allocation.stub :calculate_ids => []
      end
      it 'should process right' do
        @allocation.process!(0, 0).should == []
      end
      it 'should process right' do
        @allocation.process!(0, 10).should == []
      end
      it 'should process right' do
        @allocation.process!(20, 0).should == []
      end
      it 'should process right' do
        @allocation.process!(20, 10).should == []
      end
    end
    context 'with ids' do
      before(:each) do
        @allocation.stub :calculate_ids => [1,2,3,4,5,6,7,8,9,10]
      end
      it 'should process right' do
        @allocation.process!(0, 0).should == []
      end
      it 'should process right' do
        @allocation.process!(0, 10).should == []
      end
      it 'should process right' do
        @allocation.process!(5, 0).should == [1,2,3,4,5]
      end
      it 'should process right' do
        @allocation.process!(5, 5).should == [6,7,8,9,10]
      end
      it 'should process right' do
        @allocation.process!(20, 0).should == [1,2,3,4,5,6,7,8,9,10]
      end
      it 'should process right' do
        @allocation.process!(20, 5).should == [6,7,8,9,10]
      end
      it 'should process right' do
        @allocation.process!(20, 10).should == []
      end
    end
    context 'with symbol ids' do
      before(:each) do
        @allocation.stub :calculate_ids => [:a,:b,:c,:d,:e,:f,:g,:h,:i,:j]
      end
      it 'should process right' do
        @allocation.process!(0, 0).should == []
      end
      it 'should process right' do
        @allocation.process!(0, 10).should == []
      end
      it 'should process right' do
        @allocation.process!(5, 0).should == [:a,:b,:c,:d,:e]
      end
      it 'should process right' do
        @allocation.process!(5, 5).should == [:f,:g,:h,:i,:j]
      end
      it 'should process right' do
        @allocation.process!(20, 0).should == [:a,:b,:c,:d,:e,:f,:g,:h,:i,:j]
      end
      it 'should process right' do
        @allocation.process!(20, 5).should == [:f,:g,:h,:i,:j]
      end
      it 'should process right' do
        @allocation.process!(20, 10).should == []
      end
    end
  end
  
  describe "subject" do
    before(:each) do
      @allocation.stub :calculate_ids => [1,2,3,4,5,6,7,8,9,10]
    end
    it 'should process right' do
      @allocation.process_with_illegals!(0, 0, [1,3,7]).should == []
    end
    it 'should process right' do
      @allocation.process_with_illegals!(0, 10, [1,3,7]).should == []
    end
    it 'should process right' do
      @allocation.process_with_illegals!(5, 0, [1,3,7]).should == [2,4,5,6,8]
    end
    it 'should process right' do
      @allocation.process_with_illegals!(5, 5, [1,3,7]).should == [9,10]
    end
    it 'should process right' do
      @allocation.process_with_illegals!(20, 0, [1,3,7]).should == [2,4,5,6,8,9,10]
    end
    it 'should process right' do
      @allocation.process_with_illegals!(20, 5, [1,3,7]).should == [9,10]
    end
    it 'should process right' do
      @allocation.process_with_illegals!(20, 10, [1,3,7]).should == []
    end
  end

  describe 'to_result' do
    context 'with few combinations' do
      before(:each) do
        @allocation = described_class.new @index, double(:combinations, :empty? => false, :to_result => [:some_result])
        @allocation.instance_variable_set :@score, :some_score
      end
      context 'with ids' do
        it 'should output an array of information' do
          @backend.stub :ids => [1,2,3]

          @allocation.process! 20, 0

          @allocation.to_result.should == [:some_result_identifier, :some_score, 3, [:some_result], [1, 2, 3]]
        end
      end
    end
    context 'with results' do
      before(:each) do
        combinations = double :combinations,
                            :empty? => false,
                            :to_result => [:some_result1, :some_result2]
        @allocation = described_class.new @index, combinations
        @allocation.instance_variable_set :@score, :some_score
      end
      context 'with ids' do
        it 'should output an array of information' do
          @backend.stub :ids => [1,2,3]

          @allocation.process! 20, 0

          @allocation.to_result.should == [:some_result_identifier, :some_score, 3, [:some_result1, :some_result2], [1, 2, 3]]
        end
      end
    end
    context 'without results' do
      before(:each) do
        @allocation = described_class.new @index, double(:combinations, :empty? => true)
        @allocation.instance_variable_set :@score, :some_score
      end
      it 'should return nil' do
        @backend.stub :ids => []

        @allocation.process! 20, 0

        @allocation.to_result.should == nil
      end
    end
  end

  describe "calculate_score" do
    context 'non-empty combinations' do
      it 'should forward to backend and combinations' do
        @combinations.should_receive(:score).once.and_return 1
        boosts = double :weights, :boost_for => 2

        @allocation.calculate_score(boosts).should == 3
      end
    end
  end

  describe "<=>" do
    it "should sort higher first" do
      first = described_class.new @index, []
      first.instance_variable_set :@score, 20
      second = described_class.new @index, []
      second.instance_variable_set :@score, 10

      first.<=>(second).should == -1
    end
  end

  describe "sort!" do
    it "should sort correctly" do
      first = described_class.new @index, :whatever
      first.instance_variable_set :@score, 20
      second = described_class.new @index, :whatever
      second.instance_variable_set :@score, 10
      third = described_class.new @index, :whatever
      third.instance_variable_set :@score, 5

      allocations = [second, third, first]

      allocations.sort!.should == [first, second, third]
    end
  end

  describe "process!" do
    before(:each) do
      @amount = double :amount
      @offset = double :offset
      @ids    = double :ids, :size => :some_original_size, :slice! => :some_sliced_ids
      @allocation.stub :calculate_ids => @ids
    end
    it 'should calculate_ids' do
      @allocation.should_receive(:calculate_ids).once.with(@amount, @offset).and_return @ids

      @allocation.process! @amount, @offset
    end
    it 'should get the original ids count' do
      @allocation.process! @amount, @offset

      @allocation.count.should == :some_original_size
    end
    it 'should slice! the ids down' do
      @ids.should_receive(:slice!).once.with @offset, @amount

      @allocation.process! @amount, @offset
    end
    it 'should return the sliced ids' do
      @allocation.process!(@amount, @offset).should == :some_sliced_ids
    end
    it 'should assign the sliced ids correctly' do
      @allocation.process! @amount, @offset

      @allocation.ids.should == :some_sliced_ids
    end
  end

end