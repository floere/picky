require 'spec_helper'

describe Sources::CSV do
  
  context "without file" do
    it "should fail correctly" do
      lambda { @source = Sources::CSV.new(:a, :b, :c) }.should raise_error(Sources::NoCSVFileGiven)
    end
  end
  context "with file" do
    before(:each) do
      @source = Sources::CSV.new :a, :b, :c, :file => :some_file
      ::CSV.should_receive(:foreach).any_number_of_times.and_yield ['7', 'a data', 'b data', 'c data']
    end
    describe "harvest" do
      it "should yield the right data" do
        field = stub :b, :name => :b
        @source.harvest :anything, field do |id, token|
          [id, token].should == [7, 'b data']
        end
      end
    end
    describe "get_data" do
      it "should yield each line" do
        @source.get_data do |data|
          data.should == ['7', 'a data', 'b data', 'c data']
        end
      end
    end
  end
  
end