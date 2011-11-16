require 'spec_helper'

require 'sqlite3'

describe Picky::Backends::Sqlite::DB do

  context 'hash-based indexes' do
    let(:db) { described_class.new 'some/cache/path/to/file' }

    describe 'dump' do
      it 'delegates to the given hash' do
        hash = stub :hash

        db.should_receive(:dump_sqlite).once.with hash

        db.dump hash
      end
    end

    describe 'load' do
      it 'returns a copy of itself' do
        db.load.should == db
      end
    end

    describe 'empty' do
      it 'returns the container that is used for indexing' do
        db.empty.should == {}
      end
    end

    describe 'initial' do
      it 'is correct' do
        db.initial.should == {}
      end
    end

    describe 'to_s' do
      it 'returns the cache path with the default file extension' do
        db.to_s.should == 'Picky::Backends::Sqlite::DB(some/cache/path/to/file.sqlite3)'
      end
    end
  end

end
