require 'spec_helper'

describe Sources::Wrappers::Base do
  
  before(:each) do
    @backend  = stub :backend
    @category = stub :category, :source => @backend
  end
  
  context "with backend" do
    it "doesn't fail" do
      lambda { Sources::Wrappers::Base.new(@category) }.should_not raise_error
    end
    before(:each) do
      @wrapper  = Sources::Wrappers::Base.new @category
    end
    it "delegates harvest" do
      @backend.should_receive(:harvest).once.with :some_field
      
      @wrapper.harvest :some_field
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
  context "without backend" do
    it "fails" do
      lambda { Sources::Wrappers::Base.new }.should raise_error(ArgumentError)
    end
  end
  
end