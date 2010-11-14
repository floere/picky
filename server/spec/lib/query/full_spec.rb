require 'spec_helper'

describe Query::Full do

  before(:each) do
    @type  = stub :type
    @index = stub :index, :indexed => @type
  end

  describe 'result_type' do
    before(:each) do
      @query = Query::Full.new @index
    end
    it "should return a specific type" do
      @query.result_type.should == Results::Full
    end
  end

end