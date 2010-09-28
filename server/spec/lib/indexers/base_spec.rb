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