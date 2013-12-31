require 'spec_helper'

describe Picky::Backends::Memory::Marshal do

  context 'hash-based indexes' do
    let(:marshal) { described_class.new 'spec/temp/some/cache/path/to/file' }

    describe 'extension' do
      it 'is correct' do
        marshal.extension.should == :dump
      end
    end

    describe 'initial' do
      it 'is correct' do
        marshal.initial.should == {}
      end
    end

    describe "dump" do
      it "forwards to the given hash" do
        hash = double :hash

        marshal.should_receive(:dump_marshal).once.with hash

        marshal.dump hash
      end
    end

    describe "retrieve" do
      it "raises" do
        lambda do
          marshal.retrieve
        end.should raise_error("Can't retrieve from marshalled file. Use text file.")
      end
    end

    describe 'to_s' do
      it 'returns the cache path with the default file extension' do
        marshal.to_s.should == 'Picky::Backends::Memory::Marshal(spec/temp/some/cache/path/to/file.memory.dump)'
      end
    end
  end

end