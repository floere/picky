require 'spec_helper'

describe Picky::Backend::File::JSON do
  
  let(:file) { described_class.new 'some/cache/path/to/file' }
  
  describe "dump" do
    it "delegates to the given hash" do
      hash = stub :hash
      
      hash.should_receive(:dump_json).once.with "some/cache/path/to/file.json"
      
      file.dump hash
    end
  end
  
  describe "retrieve" do
    it "raises" do
      lambda do
        file.retrieve
      end.should raise_error("Can't retrieve from JSON file. Use text file.")
    end
  end
  
  describe 'to_s' do
    it 'returns the cache path with the default file extension' do
      file.to_s.should == 'Picky::Backend::File::JSON(some/cache/path/to/file.json)'
    end
  end
  
end