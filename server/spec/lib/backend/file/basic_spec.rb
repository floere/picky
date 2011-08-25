require 'spec_helper'

describe Picky::Backends::File::Basic do
  
  let(:file) { described_class.new 'some/cache/path/to/file' }
  
  describe 'backup_file_path_of' do
    it 'returns a backup path relative to the path' do
      file.backup_file_path_of('some/path/to/some.index').should == 'some/path/to/backup/some.index'
    end
  end
  
  describe 'backup_directory' do
    it "returns the cache path's backup path" do
      file.backup_directory.should == 'some/cache/path/to/backup'
    end
  end
  
  describe 'to_s' do
    it 'returns the cache path with the default file extension' do
      file.to_s.should == 'Picky::Backends::File::Basic(some/cache/path/to/file.index)'
    end
  end
  
end