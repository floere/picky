require 'spec_helper'

describe Picky::Backends::Memory::Text do
  
  before(:each) do
    @file = described_class.new "some_cache_path"
  end
  
  describe "load" do
    it "raises" do
      lambda do
        @file.load
      end.should raise_error("Can't load from text file. Use JSON or Marshal.")
    end
  end
  describe "dump" do
    it "raises" do
      lambda do
        @file.dump :anything
      end.should raise_error("Can't dump to text file. Use JSON or Marshal.")
    end
  end
  describe "retrieve" do
    before(:each) do
      @io = stub :io
      @io.should_receive(:each_line).once.with.and_yield '123456,some_nice_token'
      ::File.should_receive(:open).any_number_of_times.and_yield @io
    end
    it "yields split lines and returns the id and token text" do
      @file.retrieve do |id, token|
        id.should    == '123456'
        token.should == :some_nice_token
      end
    end
    it "is fast" do
      performance_of { @file.retrieve { |id, token| } }.should < 0.00005
    end
  end
  
end