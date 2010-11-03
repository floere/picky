require 'spec_helper'

describe Sources::Couch do
  
  context "without database" do
    it "should fail correctly" do
      lambda { @source = Sources::Couch.new(:a, :b, :c) }.should raise_error(Sources::NoCouchDBGiven)
    end
  end

  context "with database" do
    before(:each) do
      @source = Sources::Couch.new :a, :b, :c, {url:'http://localhost:5984/picky'}
      RestClient::Request.should_receive(:execute).any_number_of_times.and_return %{{"rows":[{"doc":{"_id":"7","a":"a data","b":"b data","c":"c data"}}]}}
    end

    describe "harvest" do
      it "should yield the right data" do
        field = stub :b, :name => :b
        @source.harvest :anything, field do |id, token|
          id.should    eql(7) 
          token.should eql('b data')
        end.should have(1).item
      end
    end

    describe "get_data" do
      it "should yield each line" do
        @source.get_data do |data|
          data.should == {"_id"=>"7", "a"=>"a data", "b"=>"b data", "c"=>"c data"}
        end.should have(1).item
      end
    end
  end
end
