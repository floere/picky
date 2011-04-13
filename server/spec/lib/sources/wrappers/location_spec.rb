require 'spec_helper'

describe Sources::Wrappers::Location do
  
  context "with backend" do
    before(:each) do
      @source   = stub :source
      @category = stub :category
    end
    context "without grid option" do
      it "fails" do
        lambda { described_class.new(:something) }.should raise_error
      end
    end
    context "with grid option" do
      before(:each) do
        @wrapper = described_class.new @source, 10
      end
      it "uses a default of 1 on the precision" do
        @wrapper.calculation.precision.should == 1
      end
      it "delegates harvest" do
        @category.stub! :exact => {}
        
        @source.should_receive(:harvest).once.with @category
        
        @wrapper.harvest @category
      end
      it "delegates take_snapshot" do
        @source.should_receive(:take_snapshot).once.with()
        
        @wrapper.take_snapshot
      end
      it "delegates connect_backend" do
        @source.should_receive(:connect_backend).once.with()
        
        @wrapper.connect_backend
      end
    end
    context "with grid and precision option" do
      before(:each) do
        @wrapper = described_class.new @category, 4, 2
      end
      it "uses the given precision" do
        @wrapper.calculation.precision.should == 2
      end
    end
  end
  context "without backend" do
    it "fails" do
      lambda { described_class.new }.should raise_error(ArgumentError)
    end
  end
  
end