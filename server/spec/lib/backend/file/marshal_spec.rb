require 'spec_helper'

describe Backend::File::Marshal do
  
  let(:file) { described_class.new 'some/cache/path/to/file' }
  
  describe "dump" do
    it "delegates to the given hash" do
      hash = stub :hash
      
      hash.should_receive(:dump_marshalled).once.with "some/cache/path/to/file.dump"
      
      file.dump hash
    end
  end
  
  describe "retrieve" do
    it "raises" do
      lambda do
        file.retrieve
      end.should raise_error("Can't retrieve from marshalled file. Use text file.")
    end
  end
  
  describe 'to_s' do
    it 'returns the cache path with the default file extension' do
      file.to_s.should == 'Backend::File::Marshal(some/cache/path/to/file.dump)'
    end
  end
  
end