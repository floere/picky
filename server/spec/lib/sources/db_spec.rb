require 'spec_helper'

describe Sources::DB do
  
  before(:each) do
    @type       = stub :type, :name => 'some_type_name'
    @connection = stub :connection
    
    @adapter          = stub :adapter, :connection => @connection
    @select_statement = stub :statement
    
    @source = Sources::DB.new @select_statement, @adapter
  end
  
  describe "count" do
    it "should get the count through the public DB connection" do
      result = stub(:result, :to_i => 12_345)
      @connection.should_receive(:select_value).once.and_return(result)
      
      @source.count @type
    end
    it "should get the id count" do
      result = stub(:result, :to_i => 12_345)
      @connection.should_receive(:select_value).once.with("SELECT COUNT(id) FROM some_type_name_type_index")
      
      @source.count @type
    end
  end

  describe "harvest" do
    before(:each) do
      @adapter.stub! :connect
      @source.stub! :harvest_statement_with_offset
    end
    context 'expectations' do
      before(:each) do
        @connection.stub! :execute
      end
      after(:each) do
        @source.harvest :some_offset, :some_chunksize
      end
      context "with WHERE" do
        before(:each) do
          @source.stub! :select_statement => 'bla WHERE blu'
        end
        it "should connect" do
          @adapter.should_receive(:connect).once.with
        end
        it "should call the harvest statement with an offset" do
          @source.should_receive(:harvest_statement_with_offset).once.with :some_offset, :some_chunksize
        end
      end
      context "without WHERE" do
        it "should connect" do
          @adapter.should_receive(:connect).once.with
        end
        it "should call the harvest statement with an offset" do
          @source.should_receive(:harvest_statement_with_offset).once.with :some_offset, :some_chunksize
        end
      end
    end
    context 'returns' do
      it "should return whatever the execute statement returns" do
        @connection.stub! :execute => :some_result
        
        @source.harvest(:some_offset, :some_chunksize).should == :some_result
      end
    end
  end

  describe "harvest_statement_with_offset" do
    before(:each) do
      @source.should_receive(:type_name).any_number_of_times.and_return :books
    end
    it "should get a harvest statement and the chunksize to put the statement together" do
      @source.should_receive(:select_statement).once.and_return 'some_example_statement'
      @source.harvest_statement_with_offset(:some_offset, :some_chunksize)
    end
    it "should add an AND if it already contains a WHERE statement" do
      @source.should_receive(:select_statement).and_return 'WHERE'
      @source.harvest_statement_with_offset(:some_offset, :some_chunksize).should == "WHERE AND st.id > some_offset LIMIT some_chunksize"
    end
    it "should add a WHERE if it doesn't already contain one" do
      @source.should_receive(:select_statement).and_return 'some_statement'
      @source.harvest_statement_with_offset(:some_offset, :some_chunksize).should == "some_statement WHERE st.id > some_offset LIMIT some_chunksize"
    end
  end
  
end