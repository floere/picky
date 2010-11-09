require 'spec_helper'

describe Index::File::JSON do
  
  before(:each) do
    @file = Index::File::JSON.new "some_cache_path"
  end
  
  describe "dump" do
    it "delegates to the given hash" do
      hash = stub :hash
      
      hash.should_receive(:dump_json).once.with "some_cache_path.json"
      
      @file.dump hash
    end
  end
  describe "retrieve" do
    it "raises" do
      lambda do
        @file.retrieve
      end.should raise_error("Can't retrieve from JSON file. Use text file.")
    end
  end
  
end