require 'spec_helper'

describe Picky::Backends::File::Basic do
  
  context 'without options' do
    let(:basic) { described_class.new 'some/cache/path/to/file' }

    describe 'empty' do
      it 'returns the container that is used for indexing' do
        basic.empty.should == {}
      end
    end
    
    describe 'initial' do
      it 'returns the container that is used for indexing' do
        basic.initial.should == nil
      end
    end

    describe 'backup_file_path_of' do
      it 'returns a backup path relative to the path' do
        basic.backup_file_path_of('some/path/to/some.memory.index').should == 'some/path/to/backup/some.memory.index'
      end
    end
  
    describe 'backup_directory' do
      it "returns the cache path's backup path" do
        basic.backup_directory('some/cache/path/to/file').should == 'some/cache/path/to/backup'
      end
    end
  
    describe 'to_s' do
      it 'returns the cache path with the default file extension' do
        basic.to_s.should == 'Picky::Backends::File::Basic(some/cache/path/to/file.file.index,some/cache/path/to/file.file_mapping.index.memory.json)'
      end
    end
  end
  
  context 'with options' do
    let(:basic) do
      described_class.new 'some/cache/path/to/file',
                          empty: [],
                          initial: []
    end

    describe 'empty' do
      it 'returns the container that is used for indexing' do
        basic.empty.should == []
      end
    end
    
    describe 'initial' do
      it 'returns the container that is used for indexing' do
        basic.initial.should == []
      end
    end
  end
  
end