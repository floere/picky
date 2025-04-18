require 'spec_helper'

require 'sqlite3'

describe Picky::Backends::SQLite::Value do
  context 'hash-based indexes' do
    let(:db) { described_class.new 'spec/temp/some/other/cache/path/to/file' }

    describe 'dump' do
      it 'forwards to the given hash' do
        hash = double :hash

        db.should_receive(:dump_sqlite).once.with hash

        db.dump hash
      end
    end

    describe 'dump_sqlite' do
      let(:client) { double :client }
      before(:each) do
        db.stub db: client
      end
      it 'initializes the client' do
        client.stub :execute

        db.should_receive(:db).exactly(4).times.with no_args

        db.dump_sqlite({})
      end
      it 'executes something' do
        db.stub :lazily_initialize_client

        client.should_receive(:execute).at_least(1).times

        db.dump_sqlite({})
      end
      it 'inserts keys and values' do
        # db.stub :db
        client.stub :execute # We only want to test the insert statements.

        client.should_receive(:execute).once.with 'insert into key_value values (?,?)', ['a', '[1,2,3]']
        client.should_receive(:execute).once.with 'insert into key_value values (?,?)', ['b', '[4,5,6]']

        db.dump_sqlite a: [1, 2, 3], b: [4, 5, 6]
      end
    end

    describe 'load' do
      it 'returns a copy of itself' do
        db.load(:anything).should == db
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
        db.to_s.should == 'Picky::Backends::SQLite::Value(spec/temp/some/other/cache/path/to/file.sqlite3)'
      end
    end
  end
end
