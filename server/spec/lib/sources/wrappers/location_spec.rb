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
        @wrapper = Sources::Wrappers::Location.new @backend, grid:10, precision:3
      end
      it "uses the given precision" do
        @wrapper.precision.should == 3
      end
    end
  end
  context "without backend" do
    it "fails" do
      lambda { Sources::Wrappers::Location.new }.should raise_error(ArgumentError)
    end
  end
  
end