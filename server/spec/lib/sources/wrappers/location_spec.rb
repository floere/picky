require 'spec_helper'

describe Sources::Wrappers::Location do
  
  context "with backend" do
    before(:each) do
      @backend = stub :backend
    end
    context "without grid option" do
      it "fails" do
        lambda { Sources::Wrappers::Location.new(:something) }.should raise_error
      end
    end
    context "with grid option" do
      before(:each) do
        @wrapper = Sources::Wrappers::Location.new @backend, grid:10
      end
      it "uses a default of 1 on the precision" do
        @wrapper.precision.should == 1
      end
      it "delegates harvest" do
        @backend.should_receive(:harvest).once.with :some_type, :some_field
        
        @wrapper.harvest :some_type, :some_field
      end
      it "delegates take_snapshot" do
        @backend.should_receive(:take_snapshot).once.with :some_type
        
        @wrapper.take_snapshot :some_type
      end
      it "delegates connect_backend" do
        @backend.should_receive(:connect_backend).once.with # nothing
        
        @wrapper.connect_backend
      end
    end
    context "with grid and precision option" do
      before(:each) do
        @wrapper = Sources::Wrappers::Location.new @backend, grid:4, precision:2
      end
      it "uses the given precision" do
        @wrapper.precision.should == 2
      end
      
      describe "locations_for" do
        before(:each) do
          @wrapper.instance_variable_set :@min, -3
          @wrapper.marginize
        end
        it "returns the right array" do
          @wrapper.locations_for(17).should == [13, 14, 15, 16, 17] # TODO Correct?
        end
        it "returns the right array" do
          @wrapper.locations_for(-3).should == [0, 1, 2, 3, 4]
        end
        it "returns the right array" do
          @wrapper.locations_for(20).should == [14, 15, 16, 17, 18]
        end
      end
    end
  end
  context "without backend" do
    it "fails" do
      lambda { Sources::Wrappers::Location.new }.should raise_error(ArgumentError)
    end
  end
  
end