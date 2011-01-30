require 'spec_helper'

describe Query::Allocation do
  
  before(:each) do
    @combinations = stub :combinations
    @allocation = Query::Allocation.new @combinations, :some_result_identifier
  end
  
  describe "eql?" do
    # TODO This works, but is not acceptable.
    #
    it "returns true" do
      @allocation.eql?(:anything).should == true
    end
  end
  
  describe "hash" do
    it "delegates to the combinations" do
      @combinations.should_receive(:hash).once.with
      
      @allocation.hash
    end
  end
  
  describe "to_s" do
    before(:each) do
      @combinations.stub! :to_result => 'combinations_result'
    end
    context "allocation.count > 0" do
      before(:each) do
        @allocation.stub! :count => 10
        @allocation.stub! :score => :score
        @allocation.stub! :ids => :ids
      end
      it "represents correctly" do
        @allocation.to_s.should == "Allocation: some_result_identifier, score, 10, combinations_result, ids"
      end
    end
  end
  
  describe 'remove' do
    it 'should delegate to the combinations' do
      @combinations.should_receive(:remove).once.with [:some_identifiers]
      
      @allocation.remove [:some_identifiers]
    end
  end
  
  describe 'keep' do
    it 'should delegate to the combinations' do
      @combinations.should_receive(:keep).once.with [:some_identifiers]
      
      @allocation.keep [:some_identifiers]
    end
  end
  
  describe 'process!' do
    context 'no ids' do
      before(:each) do
        @allocation.stub! :calculate_ids => []
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
        @allocation.stub! :calculate_ids => [1,2,3,4,5,6,7,8,9,10]
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
        @allocation.stub! :calculate_ids => [:a,:b,:c,:d,:e,:f,:g,:h,:i,:j]
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

  describe 'to_result' do
    context 'with few combinations' do
      before(:each) do
        @allocation = Query::Allocation.new stub(:combinations, :ids => [1,2,3], :to_result => [:some_result]), :some_result_identifier
        @allocation.instance_variable_set :@score, :some_score
      end
      context 'with ids' do
        it 'should output an array of information' do
          @allocation.process! 20, 0

          @allocation.to_result.should == [:some_result_identifier, :some_score, 3, [:some_result], [1, 2, 3]]
        end
      end
    end
    context 'with results' do
      before(:each) do
        combinations = stub :combinations, :ids => [1,2,3], :to_result => [:some_result1, :some_result2]
        @allocation = Query::Allocation.new combinations, :some_result_identifier
        @allocation.instance_variable_set :@score, :some_score
      end
      context 'with ids' do
        it 'should output an array of information' do
          @allocation.process! 20, 0

          @allocation.to_result.should == [:some_result_identifier, :some_score, 3, [:some_result1, :some_result2], [1, 2, 3]]
        end
      end
    end
    context 'without results' do
      before(:each) do
        @allocation = Query::Allocation.new stub(:combinations, :ids => [], :to_result => []), :some_result_identifier
        @allocation.instance_variable_set :@score, :some_score
      end
      it 'should return nil' do
        @allocation.process! 20, 0

        @allocation.to_result.should == nil
      end
    end
  end

  describe 'to_json' do
    before(:each) do
      @allocation = Query::Allocation.new stub(:combination, :ids => [1,2,3,4,5,6,7], :to_result => [:some_result1, :some_result2]), :some_result_identifier
      @allocation.instance_variable_set :@score, :some_score
    end
    it 'should output the correct json string' do
      @allocation.process! 20, 0

      @allocation.to_json.should == '["some_result_identifier","some_score",7,["some_result1","some_result2"],[1,2,3,4,5,6,7]]'
    end
  end

  describe "calculate_score" do
    it 'should delegate to the combinations' do
      @combinations.should_receive(:calculate_score).once.with :some_weights

      @allocation.calculate_score :some_weights
    end
  end

  describe "<=>" do
    it "should sort higher first" do
      first = Query::Allocation.new [], :some_result_identifier
      first.instance_variable_set :@score, 20
      second = Query::Allocation.new [], :some_result_identifier
      second.instance_variable_set :@score, 10

      first.<=>(second).should == -1
    end
  end

  describe "sort!" do
    it "should sort correctly" do
      first = Query::Allocation.new :whatever, :some_result_identifier
      first.instance_variable_set :@score, 20
      second = Query::Allocation.new :whatever, :some_result_identifier
      second.instance_variable_set :@score, 10
      third = Query::Allocation.new :whatever, :some_result_identifier
      third.instance_variable_set :@score, 5

      allocations = [second, third, first]

      allocations.sort!.should == [first, second, third]
    end
  end

  describe "process!" do
    before(:each) do
      @amount = stub :amount
      @offset = stub :offset
      @ids    = stub :ids, :size => :some_original_size, :slice! => :some_sliced_ids
      @allocation.stub! :calculate_ids => @ids
    end
    it 'should calculate_ids' do
      @allocation.should_receive(:calculate_ids).once.with.and_return @ids

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