# encoding: utf-8
#
require 'spec_helper'

describe Indexers::Field do

  before(:each) do
    @type  = stub :type, :name => :some_type, :snapshot_table_name => :some_prepared_table_name
    @field = stub :field, :name => :some_field_name, :search_index_file_name => :some_index_table
    @strategy = Indexers::Field.new :some_field_name, @type, @field
    @strategy.stub! :indexing_message
  end

  describe "chunksize" do
    it "should be a specific size" do
      @strategy.chunksize.should == 25_000
    end
  end

  describe "harvest_statement" do
    it "should be a given SQL String" do
      @strategy.harvest_statement.should == "SELECT indexed_id, some_field_name FROM some_prepared_table_name st"
    end
  end

end