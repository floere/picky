require 'spec_helper'

describe Query::Full do

  before(:each) do
    @index = stub :index
  end

  describe 'result_type' do
    before(:each) do
      @tokens = [
          Query::Token.processed('some'),
          Query::Token.processed('query')
        ]
      @query = Query::Full.new @tokens, @index
    end
    it "should return a specific type" do
      @query.result_type.should == Results::Full
    end
  end

end