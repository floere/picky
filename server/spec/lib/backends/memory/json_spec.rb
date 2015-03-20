require 'spec_helper'

describe Picky::Backends::Memory::JSON do

  context 'hash-based indexes' do
    let(:json) { described_class.new 'spec/temp/some/cache/path/to/file' }

    describe 'extension' do
      it 'is correct' do
        json.extension.should == :json
      end
    end

    describe 'initial' do
      it 'is correct' do
        json.initial.should == {}
      end
    end

    describe "dump" do
      it "forwards to the given hash" do
        hash = double :hash

        json.should_receive(:dump_json).once.with hash, File

        json.dump hash
      end
    end

    describe "retrieve" do
      it "raises" do
        lambda do
          json.retrieve
        end.should raise_error("Can't retrieve from JSON file. Use text file.")
      end
    end

    describe 'to_s' do
      it 'returns the cache path with the default file extension' do
        json.to_s.should == 'Picky::Backends::Memory::JSON(spec/temp/some/cache/path/to/file.memory.json)'
      end
    end
  end

end