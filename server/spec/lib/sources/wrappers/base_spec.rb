require 'spec_helper'

describe Sources::Wrappers::Base do
  
  before(:each) do
    @source   = stub :source
  end
  
  context "with backend" do
    it "doesn't fail" do
      lambda { described_class.new(@source) }.should_not raise_error
    end
    before(:each) do
      @wrapper = described_class.new @source
    end
    it "delegates harvest" do
      @source.should_receive(:harvest).once.with :some_category
      
      @wrapper.harvest :some_category
    end
    it "delegates take_snapshot" do
      @source.should_receive(:take_snapshot).once.with :some_index
      
      @wrapper.take_snapshot :some_index
    end
    it "delegates connect_backend" do
      @source.should_receive(:connect_backend).once.with # nothing
      
      @wrapper.connect_backend
    end
  end
  context "without backend" do
    it "fails" do
      lambda { described_class.new }.should raise_error(ArgumentError)
    end
  end
  
end