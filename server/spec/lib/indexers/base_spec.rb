require 'spec_helper'

describe Indexers::Base do

  before(:each) do
    @type  = stub :type,
                  :name => :some_type,
                  :snapshot_table_name => :some_prepared_table_name
    @field = stub :field,
                  :name => :some_field_name,
                  :search_index_file_name => :some_search_index_name,
                  :indexed_name => :some_indexed_field_name
    @strategy = Indexers::Base.new @type, @field
    @strategy.stub! :indexing_message
  end

  describe 'search_index_file_name' do
    it 'should return a specific name' do
      @strategy.search_index_file_name.should == :some_search_index_name
    end
  end

  describe 'snapshot_table' do
    it 'should return a specific name' do
      @strategy.snapshot_table.should == :some_prepared_table_name
    end
  end

  describe "index" do
    it "should execute! the indexer" do
      @strategy.should_receive(:process).once
      
      @strategy.index
    end
  end

  describe "count" do
    before(:each) do
      @connection = stub :connection
      DB::Source.stub! :connection => @connection
    end
    it "should get the count through the public DB connection" do
      result = stub(:result, :to_i => 12_345)
      @connection.should_receive(:select_value).once.and_return(result)
      
      @strategy.count
    end
    it "should get the id count" do
      result = stub(:result, :to_i => 12_345)
      @connection.should_receive(:select_value).once.with("SELECT COUNT(id) FROM some_prepared_table_name")
      
      @strategy.count
    end
  end

  describe "harvest" do
    before(:each) do
      @strategy.stub! :harvest_statement_with_offset => :some_statement
      @connection = stub :connection, :execute => nil
      DB::Source.stub! :connection => @connection
    end
    context 'expectations' do
      after(:each) do
        @strategy.harvest :some_offset
      end
      it "should execute the harvest statement with offset through the public DB connection" do
        DB::Source.connection.should_receive(:execute).once.with :some_statement
      end
      it "should call the harvest statement with an offset" do
        @strategy.should_receive(:harvest_statement_with_offset).once.with :some_offset
      end
    end
    context 'returns' do
      it "should return whatever the execute statement returns" do
        DB::Source.connection.should_receive(:execute).any_number_of_times.and_return :some_result

        @strategy.harvest(:some_offset).should == :some_result
      end
    end
  end

  describe "harvest_statement_with_offset" do
    before(:each) do
      @strategy.should_receive(:type_name).any_number_of_times.and_return :books
    end
    it "should get a harvest statement and the chunksize to put the statement together" do
      @strategy.should_receive(:harvest_statement).once.and_return 'some_example_statement'
      @strategy.should_receive(:chunksize).and_return(:some_chunksize)
      @strategy.harvest_statement_with_offset(:some_offset)
    end
    it "should add an AND if it already contains a WHERE statement" do
      @strategy.should_receive(:chunksize).and_return(:some_chunksize)
      @strategy.should_receive(:harvest_statement).and_return 'WHERE'
      @strategy.harvest_statement_with_offset(:some_offset).should == "WHERE AND st.id > some_offset LIMIT some_chunksize"
    end
    it "should add a WHERE if it doesn't already contain one" do
      @strategy.should_receive(:chunksize).and_return(:some_chunksize)
      @strategy.should_receive(:harvest_statement).and_return 'some_statement'
      @strategy.harvest_statement_with_offset(:some_offset).should == "some_statement WHERE st.id > some_offset LIMIT some_chunksize"
    end
  end
  
  # FIXME!
  #
  # describe "process" do
  #   it "should call insert count / chunksize + 1 times" do
  #     amount = 112 / 10
  #     @strategy.should_receive(:count).and_return 112
  #     @strategy.should_receive(:chunksize).and_return 10
  #     @strategy.should_receive(:harvest).any_number_of_times
  # 
  #     @strategy.should_receive(:insert!).exactly(amount + 1).times
  # 
  #     @strategy.process
  #   end
  #   it "should harvest the right ids" do
  #     amount = 112 / 10
  #     @strategy.should_receive(:count).and_return 112
  #     @strategy.should_receive(:chunksize).and_return 10
  #     @strategy.should_receive(:insert!).any_number_of_times
  # 
  #     0.step(110, 10) do |n|
  #       @strategy.should_receive(:harvest).once.with n
  #     end
  #     @strategy.should_receive(:harvest).never.with(120)
  # 
  #     @strategy.process
  #   end
  # end

end