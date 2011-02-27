require 'spec_helper'

describe Internals::Index::File::Marshal do
  
  before(:each) do
    @file = described_class.new "some_cache_path"
  end
  
  describe "dump" do
    it "delegates to the given hash" do
      hash = stub :hash
      
      hash.should_receive(:dump_marshalled).once.with "some_cache_path.dump"
      
      @file.dump hash
    end
  end
  describe "retrieve" do
    it "raises" do
      lambda do
        @file.retrieve
      end.should raise_error("Can't retrieve from marshalled file. Use text file.")
    end
  end
  
end