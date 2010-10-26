require 'spec_helper'

describe Index::File::Text do
  
  before(:each) do
    @file = Index::File::Text.new "some_cache_path"
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
    it
  end
  
end